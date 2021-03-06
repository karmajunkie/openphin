# == Schema Information
#
# Table name: documents
#
#  id                :integer(4)      not null, primary key
#  owner_id          :integer(4)
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer(4)
#  file_updated_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  user_id           :integer(4)
#  folder_id         :integer(4)
#

class Document < ActiveRecord::Base
  has_attached_file :file, :path => ":rails_root/attachments/:attachment/:id/:filename"
  validates_attachment_presence :file

  has_and_belongs_to_many :channels, :after_add => :share_with_channel
  has_many :targets, :as => :item, :after_add => :share
  has_many :audiences, :through => :targets
  accepts_nested_attributes_for :audiences
    
  belongs_to :user
  belongs_to :folder
  belongs_to :owner, :class_name => 'User'

  after_post_process :notify_channels_of_update

  named_scope :viewable_by, lambda{|user|
    {:conditions => ['documents.user_id = :user OR subscriptions.user_id = :user', {:user => user}],
    :include => {:channels => :subscriptions}}
  }

  named_scope :editable_by, lambda{|user|
    {:conditions => ['documents.user_id = :user OR (subscriptions.user_id = :user AND subscriptions.owner = :true)', {:user => user, :true => true}],
    :include => {:channels => :subscriptions}}
  }
  
  def viewable_by?(user)
    Document.viewable_by(user).exists?(id)
  end
  
  def editable_by?(user)
    Document.editable_by(user).exists?(id)
  end
  
  def to_s
    file_file_name
  end
  
  # used by Target to determine if public users should be included in recipients
  def include_public_users?
    false
  end
  
  def share(target)
    target.users.each do |user|
      self.copy(user)
    end
    DocumentMailer.deliver_document(self, target)
  end
  
  def share_with_channel(channel)
    DocumentMailer.deliver_document_addition(channel, self) unless channel.users.empty?
  end
  
  def notify_channels_of_update
    channels.each do |channel|
      recipients = channel.users
      unless recipients.empty?
        DocumentMailer.deliver_document_update(self, recipients, channel)
      end
    end
  end
  
  def copy(user)
    user.documents.create! :file => self.file, :owner => user
  end

private
  
 
=begin
  # callback used for delayed asynchronous processing
  # save entry in database but holdoff upload processing
  before_data_post_process do |document|
    false if document.processing?  # do not process if just added
  end
  
  # callback used for delayed asynchronous processing
  # add the document to the delayed job queue
  after_create do |document|
    Delayed::Job.enqueue DocumentJob.new(document.id)
  end
  
  # used for delayed asynchronous processing
  def perform
    self.processing = false # unlock for processing
    data.reprocess! # do the processing
    save
  end
=end
  
  
end
