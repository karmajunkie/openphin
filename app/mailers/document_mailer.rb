class DocumentMailer < ActionMailer::Base
  
  def document(document, target)
    bcc target.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} shared a document with you"
    body :document => document
  end
  
  def channel_invitation(channel, target)
    bcc target.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} invited you to a channel"
    body :channel => channel
  end
  
  def document_addition(channel)
    bcc channel.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject %Q{A document has been added to the channel "#{channel}"}
    body :channel => channel
  end
  
  def document_update(document, users)
    bcc users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "A document has been updated"
    body :document => document
  end
end