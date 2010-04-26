class Service::SWN::Email::Alert < Service::SWN::Email::Base
  include ActionController::UrlWriter

  property :alert
  property :users
  property :username
  property :password
  property :retry_duration

  validates_presence_of :alert, :username, :password, :retry_duration, :users

  def self.format_activation_time(time)
    time.strftime("%Y%m%d%H%M%S")
  end

  def retry_duration=(duration)
    @retry_duration = duration.to_s.scan(/\d+/).first.to_i.hours
  end

  def build!
    raise "Invalid #{self}, Errors: #{self.errors.full_messages.inspect}" unless valid?

    body = ""
    xml = Builder::XmlMarkup.new :target => body, :indent => 2
    #xml.instruct!
    xsi = "xmlns:xsi".to_sym
    xsd = "xmlns:xsd".to_sym
    soapenv = "xmlns:soap-env".to_sym
    soapenc = "xmlns:soap-enc".to_sym
    xml.tag!("soap-env:Envelope", xsi => "http://www.w3.org/2001/XMLSchema-instance", xsd => "http://www.w3.org/2001/XMLSchema",
      soapenv => "http://schemas.xmlsoap.org/soap/envelope/", soapenc => "http://schemas.xmlsoap.org/soap/encoding/") do
      add_header xml
      xml.tag!("soap-env:Body") do
        add_send_notification xml
      end
    end
    unless alert.message_recording_file_name.blank?
    body = <<EOF
--MIME_boundary
Content-Type: text/xml; charset=UTF-8
Content-Transfer-Encoding: 8bit
Content-ID: <#{alert.distribution_id}@#{Agency[:agency_domain]}>

#{body}
--MIME_boundary
Content-Type: audio/x-avi
Content-Transfer-Encoding: binary
Content-Location: "#{alert.message_recording_file_name}"

#{Base64.encode64(IO.read(alert.message_recording.path))}
--MIME_boundary--

EOF
    end

  body

  end

  private

  def add_header(xml)
    xml.tag!("soap-env:Header") do
      xml.AuthCredentials :xmlns => "http://www.sendwordnow.com/notification" do
        xml.username username
        xml.password password
      end
    end
  end

  def add_send_notification(xml)
    xmlns = "xmlns:swn".to_sym
    xml.swn(:sendNotification, xmlns => "http://www.sendwordnow.com/notification") do
      xml.swn(:pSendNotificationInfo) do
        xml.swn(:SendNotificationInfo) do
          xml.swn(:id, alert.distribution_id)
          xml.swn(:custSentTimestamp, Time.now.utc.iso8601(3))
          add_sender xml
          add_notification xml
          add_alert_responses xml

          add_recipients xml
	        #TODO: uncomment if and when SWN introduces ability to attach voice files.
#          add_program_content_with_audio xml unless alert.message_recording_file_name.blank?
        end
      end
    end
  end

  def add_sender(xml)
    xml.swn(:sender) do
      xml.swn(:introName, alert.author.display_name) unless alert.author.nil?
      xml.swn(:introOrganization, alert.from_organization) unless alert.from_organization.blank?
      xml.swn(:introOrganization, alert.from_jurisdiction) unless alert.from_jurisdiction.blank?
      xml.swn(:email, alert.author.email) unless alert.author.nil?      
    end
  end

  def add_notification(xml)
    xml.swn(:notification) do
      severity = "#{alert.severity}"
      status = " #{alert.status}" if alert.status.downcase != "actual"
      xml.swn(:subject, "#{severity} Health Alert#{status} \"#{alert.title}\"#{alert.acknowledge? ? " *Acknowledgment required*" : ""}")
      xml.swn(:body, "The following is an alert from the Texas Public Health Information Network.\r\n\r\n#{construct_message}")
    end
  end

  def add_alert_responses(xml)
    if alert.acknowledge?
      if alert.has_alert_response_messages? && alert.original_alert.nil?
        sorted_messages = alert.call_down_messages.sort {|a, b| a[0]<=>b[0]}
        sorted_messages.each do |key, call_down|
          xml.swn(:gwbText, call_down)
        end
      else
        xml.swn(:gwbText, "Please press one to acknowledge this alert.")
      end
    end

  end

  def add_recipients(xml)
    xml.swn(:rcpts) do
      users.each do |user|
        xml.swn(:rcpt) do
          xml.swn(:id, user.id)
          xml.swn(:firstName, user.first_name)
          xml.swn(:lastName, user.last_name)
          xml.swn(:contactPnts) do
            user.devices.email.each do |email_device|
              xml.swn(:contactPntInfo, :type => "Email") do
                xml.swn(:id, email_device.id)
                xml.swn(:label, "Email Device")
                xml.swn(:address, email_device.email_address)
              end
            end
          end
        end
      end
    end
  end

#  def add_program_content_with_audio(xml)
#      xml.swn(:soundName, alert.message_recording_file_name )
#  end

  def construct_message
    default_url_options[:host] = HOST
    output = ""
    if @alert.sensitive?
      output += "Alert ID: #{@alert.identifier}\r\n"
      output += "Reference: #{@alert.original_alert_id}\r\n" unless @alert.original_alert_id.blank?
      output += "Sensitive: use secure means of retrieval\r\n\r\n"
      output += "Please visit #{url_for(:action => "show", :controller => "alerts", :id => @alert.id, :escape => false, :only_path => false, :protocol => "https")} to securely view this alert.\r\n"
    else
      if @alert.acknowledge?
        if @alert.has_alert_response_messages?
          @alert.call_down_messages.each do |key, value|
            output += "#{value}, please click the following link #{email_acknowledge_alert_url(@alert, key)}\r\n"
          end
        else
          output += "Please click #{email_acknowledge_alert_url(@alert)} and log in to acknowledge this alert\r\n"
        end
      end

      output += "Title: #{@alert.title}\r\n"
      output += "Alert ID: #{@alert.identifier}\r\n"
      output += "Reference: #{@alert.original_alert_id}\r\n" unless @alert.original_alert_id.blank?
      output += "Agency: #{@alert.from_jurisdiction.nil? ? @alert.from_organization_name : @alert.from_jurisdiction.name}\r\n"
      output += "Sender: #{@alert.author.display_name}\r\n" unless @alert.author.nil?
      output += "Time Sent: #{@alert.created_at.strftime("%B %d, %Y %I:%M %p %Z")}\r\n\r\n"
      output += @alert.message
    end
    output
  end
end