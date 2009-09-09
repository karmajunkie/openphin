u = User.seed(:email) do |m|
  m.first_name = 'Keith'
  m.last_name = 'Gaddis'
  m.email = 'keith@example.com'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.admin.id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Bob'
  m.last_name = 'Dole'
  m.email = 'bob@example.com'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter').id
  r.role_id = Role.org_admin.id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter').id
  r.role_id = Role.admin.id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter').id
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Ethan'
  m.last_name = 'Waldo'
  m.email = 'ethan@example.com'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.email = 'jason@example.com'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter').id
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Brandon'
  m.last_name = 'Keepers'
  m.email = 'brandon@example.com'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Potter').id
  r.role_id = Role.find_by_name('Health Officer').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Daniel'
  m.last_name = 'Morrison'
  m.email = 'daniel@example.com'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Wise').id
  r.role_id = Role.find_by_name('Health Officer').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Zach'
  m.last_name = 'Dennis'
  m.email = 'zach@example.com'
  m.email_confirmed = false
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.email = 'jason@texashan.org'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.admin.id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.email = 'jphipps@texashan.org'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Wise').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Wise').id
  r.role_id = Role.admin.id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Wise').id
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.email = 'jphipps@talho.org'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Wise').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Jason'
  m.last_name = 'Phipps'
  m.email = 'jason.phipps@earthlink.net'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Texas').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

u = User.seed(:email) do |m|
  m.first_name = 'Ethan'
  m.last_name = 'Weirdo'
  m.email = 'ewaldo@talho.org'
  m.email_confirmed = true
  m.password = 'Password1'
  m.password_confirmation = 'Password1'
end

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Armstrong').id
  r.role_id = Role.find_by_name('Public').id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Armstrong').id
  r.role_id = Role.admin.id
  r.user_id = u.id
end
u.role_memberships << r

r = RoleMembership.seed(:jurisdiction_id, :role_id, :user_id) do |r|
  r.jurisdiction_id = Jurisdiction.find_by_name('Armstrong').id
  r.role_id = Role.find_by_name('Health Alert and Communications Coordinator').id
  r.user_id = u.id
end
u.role_memberships << r
