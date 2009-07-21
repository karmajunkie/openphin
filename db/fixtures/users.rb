u = User.seed(:first_name, :last_name) do |m|
  m.first_name = 'Keith'
  m.last_name = 'Gaddis'
  m.email = 'keith@example.com'
  m.email_confirmed = true
  m.password = 'password'
  m.password_confirmation = 'password'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas')
  r.role_id = Role.admin
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:first_name, :last_name) do |m|
  m.first_name = 'Ethan'
  m.last_name = 'Waldo'
  m.email = 'ethan@example.com'
  m.email_confirmed = true
  m.password = 'password'
  m.password_confirmation = 'password'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas')
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator')
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:first_name, :last_name) do |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.email = 'jason@example.com'
  m.email_confirmed = true
  m.password = 'password'
  m.password_confirmation = 'password'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter County')
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator')
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:first_name, :last_name) do |m|
  m.first_name = 'Brandon'
  m.last_name = 'Keepers'
  m.email = 'brandon@example.com'
  m.email_confirmed = true
  m.password = 'password'
  m.password_confirmation = 'password'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter County')
  r.role_id = Role.find_by_name('Health Officer')
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:first_name, :last_name) do |m|
  m.first_name = 'Daniel'
  m.last_name = 'Morrison'
  m.email = 'daniel@example.com'
  m.email_confirmed = true
  m.password = 'password'
  m.password_confirmation = 'password'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Wise County')
  r.role_id = Role.find_by_name('Health Officer')
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:first_name, :last_name) do |m|
  m.first_name = 'Zach'
  m.last_name = 'Dennis'
  m.email = 'zach@example.com'
  m.email_confirmed = false
  m.password = 'password'
  m.password_confirmation = 'password'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter County')
  r.role_id = Role.find_by_name('Public')
  r.user_id = u.id
end
u.role_memberships << r