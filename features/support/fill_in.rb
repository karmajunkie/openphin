module FeatureHelpers
  module FillInMethods

    def fill_in_fcbk_control(name, use_email=true)
      if use_email
        user = Given "a user named #{name.strip}"
        name_array = user.email.split("")
      else
        name_array = name.split("")
      end
      wait_until{page.find(".maininput").nil? == false}
      div_elem = page.find(".maininput")
      div_elem.click
      name_array.each do |c|
        is_click = false
        div_elem.set(div_elem.value + c)
        begin
          wait_until{page.find("li.outer").nil? == false}
          sleep 0.5
          page.find("li.outer").click
          is_click = true
        rescue
        end
        break if is_click
      end
    end

    def remove_from_fcbk_control(name)
      page.find("a.closebutton").click
      sleep 0.5
    end
    
    def fill_in_user_signup_form(table=nil)
      fields={"Email"=> "john@example.com",
       "Password"=> "Password1",
       "Password Confirmation"=> "Password1",
       "First Name"=> "John",
       "Last Name"=> "Smith",
       "Preferred name"=> "Jonathan Smith",
       "Are you a public health professional?" => '<unchecked>',
       "Preferred language"=> "English"
      }
      
      if table.is_a?(Hash)
        fields.merge!(table)
      elsif !table.nil?
        fields.merge!(table.rows_hash)
      end
      
      fill_in_signup_form(fields)
    end
    
    def fill_in_signup_form(table = nil)
      fields = {}
      if table.is_a?(Hash)
        fields.merge!(table)
      elsif !table.nil?
        fields.merge!(table.rows_hash)
      end

      fields.each do |field, value|
        value = "" if value == "<blank>"
        case field
        when 'Email', 'Password', 'Password Confirmation', 'First Name', 'Last Name', 'Preferred name', 'Street', 'City', 'State', 'Zip', 'Organization', 'Phone', 'Fax', 'Description', 'Please describe your role', 'Distribution Email', 'Name', 'Email Address', 'Phone Number'
          fill_in field, :with => value
        when 'Preferred language'
          find_field(field).select(value.strip)
        when 'What is your primary role',
          'Are you with any of these organizations', 'Organization Type'
          # must have the if below since check really behaves like toggle
          page.check("health_professional") if !find(:css, "#health_professional").node.selected?
          select value.strip, :from => field
        when /Jurisdiction of Operation/
          field = find_field("organization_jurisdiction_ids")
          value.split(',').each do |id|
            field.select(id.strip)
          end
        when "Are you a public health professional?"
          id = "health_professional"
          if value == "<unchecked>"
            page.uncheck(id) if find(:css, "##{id}").node.selected?
          else
            page.check(id) if !find(:css, "##{id}").node.selected?
          end
        when "Home Jurisdiction"
          value = "" if value.nil?
          find_field("user_role_requests_attributes_0_jurisdiction_id").select(value)
        when "State Jurisdiction"
          find_field(Jurisdiction.find_by_name(value).name).click
        else
          raise "Unknown field: #{field}: Please update this step if you intended to use this field."
        end
      end
    end
  
    def fill_in_alert_form(table = nil)
      fields = {
        #"Title" => "H1N1 SNS push packs to be delivered tomorrow",
        "Message" => "For more details, keep on reading...",
        "Severity" =>"Moderate",
        #"Status" => "Actual",
        "Acknowledge"  => "Normal",
        #"Communication methods" => "E-mail",
        "Delivery Time" => "15 minutes"
      }

      if table.is_a?(Hash)
        fields.merge!(table)
      elsif !table.nil?
        fields.merge!(table.rows_hash)
      end

      details = Hash[fields.select {|key, value| ["Title","Message","Short Message","Communication methods","Communication method","Jurisdiction",
                                             "Status","Severity","Delivery Time","Acknowledge","Sensitive","Alert Response 1",
                                             "Alert Response 2","Alert Response 3","Alert Response 4","Alert Response 5"].include?(key)}]
      audience = Hash[fields.select {|key, value| ["Jurisdictions","Roles","Role","Organizations","Organization","Groups","Group","People"].include?(key)}]

      ["Alert Response 1","Alert Response 2","Alert Response 3","Alert Response 4","Alert Response 5"].each do |resp|
        raise "Cannot fill in Alert Responses without Advanced acknowledgment" if details.has_key?(resp) && details["Acknowledge"] != "Advanced"
        fill_in_alert_field("Acknowledge",details["Acknowledge"])
      end
      
      details.each do |label, value|
        fill_in_alert_field(label, value)
      end
      if audience.size > 0
        When "I press \"Select an Audience\""
        audience.each do |label, value|
          fill_in_alert_field(label, value)
        end
      end
    end

    def fill_in_audience_form(table)
      table.rows_hash.each do |field, value|
        fill_in_audience_field field, value
      end
    end
    
    def fill_in_audience_field(label, value)
      case label
      when "People"
        value.split(',').each { |name| fill_in_fcbk_control(name) }
      when /Jurisdictions/, /Role[s]?/, /Organization[s]?/, /^Groups?$/
        value.split(',').map(&:strip).each{ |r| check r }
      else
        false
      end
    end
  
    def fill_in_alert_field(label, value)
      case label
      when "People"
        value.split(',').each { |name| fill_in_fcbk_control(name) }
      when /Jurisdictions/, /Role[s]?/, /Organization[s]?/, /^Groups?$/, /^Communication methods?/
        value.split(',').map(&:strip).each{ |r| check r }
        when 'Acknowledge', 'Status', 'Severity', 'Jurisdiction','Event Interval'
          select value, :from => label
        when 'Delivery Time'
          case value
            when /^(\d+) hours$/ then
              if Alert::DeliveryTimes.include?($1.to_i.hours.to_i/1.minute.to_i)
                select value, :from => "alert_delivery_time"
              else
                raise "Not a valid Delivery Time"
            end
            when /^(\d+) minutes$/ then
              if Alert::DeliveryTimes.include? $1.to_i
                select value, :from => "alert_delivery_time"
              else
                raise "Not a valid Delivery Time"
            end
            else
              raise "Not a valid Delivery Time"
          end
        when 'Acknowledge', 'Sensitive'
          id = "alert_#{label.parameterize('_')}"
          if value == '<unchecked>'
            uncheck id
          else
            check id
          end
      when 'Communication methods'
        check value

      when "Message Recording"
        attach_file(:alert_message_recording, File.join(RAILS_ROOT, 'features', 'fixtures', value), "audio/x-wav")
      when "Short Message"
        fill_in "alert_short_message", :with => value
      when "Title"
        fill_in label, :with => value
      when "Message"
        # instantly set the message text to avoid javascript not responding
        # dialog notice in firefox
        page.execute_script("$('#alert_message').val('#{value}')")
      when "Alert Response 1", "Alert Response 2", "Alert Response 3", "Alert Response 4", "Alert Response 5"
        fill_in label, :with => value
      else
        raise "Unexpected: #{label} with value #{value}. You may need to update this step."
      end
    end

    def fill_in_assign_role_form(table)
      table.rows_hash.each do |label, value|
        case label
        when "People"
          value.split(',').each { |name| fill_in_fcbk_control(name) }
        when "Role", "Jurisdiction"
          select value.split(',').map(&:strip), :from => label
        else
          raise "Unknown field '#{label}'. You may need to update this step."
        end
      end
    end

    def fill_in_group_form(table = nil)
      table.rows_hash.each do |label, value|
        fill_in_group_field label, value
      end
    end

    def fill_in_group_field(label, value)
      case label
      when "Users"
        value.split(',').each { |name| fill_in_fcbk_control(name) }
      when 'Name'
        fill_in "group_#{label.downcase}", :with => value
      when'Scope'
        select value, :from => "group_#{label.downcase}"
      when /^Jurisdiction[s]$/, /Role[s]?/
        value.split(',').map(&:strip).each{ |r| check r }
      when 'Owner Jurisdiction'
        select value, :from => label
      else
        raise "Unexpected: #{label} with value #{value}. You may need to update this step."
      end
    end
  end

end

World(FeatureHelpers::FillInMethods)
