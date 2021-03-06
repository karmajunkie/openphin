class RoleRequestObserver < ActiveRecord::Observer
  observe RoleRequest
  
  def after_create(role_request)
    return if role_request.approved?
    role_request.jurisdiction.admins.each do |admin|
      SignupMailer.deliver_admin_notification_of_role_request(role_request, admin) unless !role_request.user.email_confirmed?
    end
  end
end
    