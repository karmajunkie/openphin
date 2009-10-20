# == Schema Information
#
# Table name: audiences
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  owner_id              :integer(4)
#  scope                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  owner_jurisdiction_id :integer(4)
#  type                  :string(255)
#

class Audience < ActiveRecord::Base
  validates_presence_of :owner

  belongs_to :owner, :class_name => "User"
  belongs_to :owner_jurisdiction, :class_name => "Jurisdiction"
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :users
  has_many :group_snapshots
  has_many :alerts, :through => :group_snapshots


  SCOPES = ['Personal', 'Jurisdiction', 'Global']

  named_scope :personal, lambda{{:conditions => ["scope = ?", "Personal"]}}
  named_scope :jurisdictional, lambda{{:conditions => ["scope = ?", "Jurisdiction"]}}
  named_scope :global, lambda{{:conditions => ["scope = ?", "Global"]}}

  validates_presence_of :owner
  validates_length_of :name, :allow_nil => false, :allow_blank => false, :within => 1..254 
  validates_inclusion_of :scope, :in => SCOPES
  validates_presence_of :owner_jurisdiction, :if => Proc.new{|group| group.scope == "Jurisdiction"}
  validate :at_least_one_scope?

  def self.by_jurisdictions(jurisdictions)
    jur_ids = jurisdictions.map(&:id).compact.uniq
    Group.find_all_by_owner_jurisdiction_id(jur_ids)
  end

	def create_snapshot
		snap=group_snapshots.create
		snap.users = current_users
    snap.save
		snap
  end

  def current_users
    unless @_current_users
      userlist=users
      if jurisdictions.any? && roles.any?
        userlist << jurisdictions.map{|j| j.users.with_roles(roles)}.flatten
      elsif jurisdictions.any? && roles.empty?
        userlist << jurisdictions.map(&:users).flatten
      elsif jurisdictions.empty? && roles.any?
        userlist << roles.map(&:users).flatten
      end
      @_current_users=userlist
    end
    @_current_users
  end

  private
  def at_least_one_scope?
    if roles.empty? & jurisdictions.empty? & users.empty?
      errors.add_to_base("You must select at least one role, one jurisdiction, or one user.")
    end
  end
end