# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  last_name          :string(255)
#  phin_oid           :string(255)
#  description        :text
#  display_name       :string(255)
#  first_name         :string(255)
#  email              :string(255)
#  preferred_language :string(255)
#  title              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(128)
#  salt               :string(128)
#  token              :string(128)
#  token_expires_at   :datetime
#  email_confirmed    :boolean         not null
#  phone              :string(255)
#

# Required Attributes: :cn, :sn, :organizations

class User < ActiveRecord::Base
  include Clearance::User
  
  has_many :devices
  accepts_nested_attributes_for :devices
  
  has_many :role_memberships
  has_many :role_requests, :foreign_key => "requester_id"
  accepts_nested_attributes_for :role_requests
  
  has_and_belongs_to_many :organizations
  has_many :jurisdictions, :through => :role_memberships 
  has_many :roles, :through => :role_memberships
  has_many :alerts, :foreign_key => 'author_id'
  has_many :alert_attempts
  has_many :deliveries, :through => :alert_attempts
  has_one :profile, :class_name => "UserProfile"
  has_many :alert_attempts

  validates_uniqueness_of :email
  validates_presence_of :email
  validates_presence_of :first_name
  validates_presence_of :last_name
  attr_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title, :organization_ids, :role_requests_attributes
    
  before_create :generate_oid
  before_create :set_confirmation_token
  before_create :create_default_email_device

  after_create :assign_public_role
  after_create :create_default_profile

  named_scope :with_role, lambda {|role| 
    role = role.is_a?(Role) ? role : Role.find_by_name(role)
    { :conditions => [ "role_memberships.role_id = ?", role.id ]}
  }
  named_scope :with_jurisdiction, lambda {|jurisdiction|
    jurisdiction = jurisdiction.is_a?(Jurisdiction) ? jurisdiction : Jurisdiction.find_by_name(jurisdiction)
    { :conditions => [ "role_memberships.jurisdiction_id = ?", jurisdiction.id ], :include => :role_memberships}
  }

#  named_scope :acknowledged_alert, lamda {|alert|
#	  { :include => :alert_attempts, :conditions => ["alert_attempts.acknowledged_at is not null"] }
#  }
  
  named_scope :alphabetical, :order => 'last_name, first_name, display_name'
  
  def self.assign_role(role, jurisdiction, users)
    users.each do |u|
      u.role_memberships.create(:role => role, :jurisdiction => jurisdiction)
    end
  end

  def self.search(query)
    all(:conditions => ['first_name LIKE :query OR last_name LIKE :query OR display_name LIKE :query OR title LIKE :query', {:query => "%#{query}%"}])
  end

  def is_admin_for?(jurisdiction)
    jurisdiction.admins.include?(self)
  end
  
  def is_super_admin?
    j = Jurisdiction.find_by_name('Texas')
    j.admins.include?(self) unless j.nil?
  end

  def is_admin?
    self.jurisdictions.each do |j|
      return true if j.admins.include?(self)
    end
    false
  end

  def is_org_approver?
    self.roles.detect{|role| role == Role.org_admin }
  end

  def display_name
    self[:display_name].blank? ? first_name + " " + last_name : self[:display_name]
  end
  alias_method :name, :display_name
  
  def phin_oid=(val)
    raise "PHIN oids should never change"
  end

  def to_dsml(builder=nil)
    builder=Builder::XmlMarkup.new( :indent => 2) if builder.nil?
    builder.dsml(:entry, :dn => dn) do |entry|
      entry.dsml:objectclass do |oc|
        ocv="oc-value".to_sym
        oc.dsml ocv, "top"
        oc.dsml ocv, "person"
        oc.dsml ocv, "organizationalPerson"
        oc.dsml ocv, "inetOrgPerson"
        oc.dsml ocv, "User"

      end
      entry.dsml(:attr, :name => :cn) {|a| a.dsml :value, mail}
      entry.dsml(:attr, :name => :sn) {|a| a.dsml :value, sn}
      entry.dsml(:attr, :name => :externalUID) {|a| a.dsml :value, externalUID}
      entry.dsml(:attr, :name => :description) {|a| a.dsml :value, description}
      entry.dsml(:attr, :name => :displayName) {|a| a.dsml :value, displayName}
      entry.dsml(:attr, :name => :givenName) {|a| a.dsml :value, givenName}
      entry.dsml(:attr, :name => :mail) {|a| a.dsml :value, mail}
      entry.dsml(:attr, :name => :preferredlanguage) {|a| a.dsml :value, preferredlanguage}
      entry.dsml(:attr, :name => :title) {|a| a.dsml :value, title}
      entry.dsml(:attr, :name => :roles) do |r|
        phinroles.each do |role|
          r.dsml(:value, role.cn)
        end
      end
      entry.dsml(:attr, :name => :roleJurisdiction) {|a| a.dsml :value, roleJurisdiction}
      entry.dsml(:attr, :name => :organizations) do |o|
        organizations.each do |org|
          o.dsml(:value, org)
        end
      end
      entry.dsml(:attr, :name => :cn) {|a| a.dsml :value, cn}

    end
  end

  def request_roles
    role_memberships.each do |rm|
      if rm.needs_approval?
        rm.request_approval
      end
    end
  end
  
  def alerter?
    !role_memberships.alerter.empty?
  end
  
  def formatted_email
    "#{name} <#{email}>"
  end

  def alerts_within_jurisdictions
    j = jurisdictions.map{|m| m.self_and_descendants}.flatten
    Alert.all(:conditions => {:from_jurisdiction_id => j})
  end
  
private

  def assign_public_role
    public_role = Role.find_by_name("Public")
    role_requests.find_all_by_role_id(public_role).each do |request|
      role_memberships.create!(
        :role => public_role, 
        :jurisdiction => request.jurisdiction
      )
      request.destroy
    end
        
    if self.role_requests.any?
      self.role_memberships.find_or_create_by_role_id_and_jurisdiction_id(
        public_role.id, 
        self.role_requests.first.jurisdiction.id
      )
    end
  end

  def generate_oid
    self[:phin_oid] = email.to_phin_oid
  end
  
  def create_default_email_device  
    email = Device::EmailDevice.new(:email_address => self.email)
    devices << email
  end
    
  def set_confirmation_token
    self.token = ActiveSupport::SecureRandom.hex
  end

	def create_default_profile
		self.create_profile(:public => false)
	end

end
