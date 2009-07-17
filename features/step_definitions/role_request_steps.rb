Given /^"([^\"]*)" has requested to be a "([^\"]*)" for "([^\"]*)"$/ do |user_email, role_name, jurisdiction_name|
  user=User.find_by_email(user_email) || Factory(:user, :email => user_email)
  role=Role.find_by_name(role_name) || Factory(:role, :name => role_name)
  jurisdiction = Jurisdiction.find_by_name(jurisdiction_name) ||  Factory(:jurisdiction, :name => jurisdiction_name)
  req = Factory(:role_request,
                    :jurisdiction => jurisdiction,
                    :role => role,
                    :requester => user)
end


When /^I fill out the role request form with:$/ do |table|
  table.rows_hash.each do |label, value|
    case label
    when /Jurisdiction/i, /Role/i
      select value, :from => label
    else
      raise "The field '#{field}' is not supported, please update this step if you intended to use it"
    end
  end
  click_button 'Submit Request'
end

When /^I approve "([^\"]*)" in the role "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_requester_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)
  visit approve_admin_role_request_path(request) 
end

When /^I deny "([^\"]*)" in the role "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_requester_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)
  visit deny_admin_role_request_path(request)
end

Then /^I should see 0 pending role requests$/ do
  response.should_not have_selector(".pending_role_requests .request")
  current_user.jurisdictions.first.role_requests.count.should == 0
end

Then /^I should not see that "([^\"]*)" is awaiting approval$/ do |user_email|
  visit admin_role_requests_path
  response.should_not have_selector( ".pending_role_requests") do |req|
    req.should have_selector(".requester_email", :content => user_email)
  end
end

Then /^I should see that I have a pending role request$/ do
  current_user.role_requests.should_not be_empty
end

Then /^I should see I am awaiting approval for (.*) in (.*)$/ do |role_name, jurisdiction_name|
  role = Role.find_by_name!(role_name)
  jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
  request = current_user.role_requests.unapproved.detect{ |request| request.jurisdiction == jurisdiction && request.role == role }
  request.should_not be_nil
  
  visit dashboard_path
  response.should have_selector( ".pending_role_requests") do |req|
    req.should contain(role_name)
    req.should contain(jurisdiction_name)
  end
end

Then /^I should see "([^\"]*)" is awaiting approval for "([^\"]*)"$/ do |user_email, role_name|
  request=RoleRequest.find_by_requester_id_and_role_id_and_jurisdiction_id(
          User.find_by_email!(user_email).id,
          Role.find_by_name!(role_name).id,
          current_user.jurisdictions.first.id)

  visit admin_role_requests_path
  response.should have_selector( ".pending_role_requests") do |req|
    req.should have_selector(".requester_email", :content => user_email)
    req.should have_selector(".role", :content => role_name)
    req.should have_selector(".jurisdiction", :content => current_user.jurisdictions.first.name )
    req.should have_selector("a.approve_link[href='#{approve_admin_role_request_path(request)}']")
    req.should have_selector("a.deny_link[href='#{deny_admin_role_request_path(request)}']")
  end
end