set :application, "openphin"
set :repository,  "git://github.com/talho/openphin.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
 set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
RAILS_ENV="production"

role :app, "192.168.30.115"
role :web, "192.168.30.115"
role :db,  "192.168.30.115", :primary => true
set :scm, :git
set :branch, 'master'
set :use_sudo, false
set :user, 'apache'
set :git_enable_submodules, true
set :ssh_options, {:forward_agent => true}
set :deploy_via, :remote_cache
 
desc "mod_rails restart"
  namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
 
after 'deploy:update_code', 'deploy:symlink_configs'
after 'deploy:update_code', 'deploy:install_gems'
after "deploy", "deploy:cleanup"
namespace :deploy do
  desc "we need a database. this helps with that."
  task :symlink_configs do
    run "mv #{release_path}/config/database.yml.example #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/#{RAILS_ENV}.sqlite3 #{release_path}/db/#{RAILS_ENV}.sqlite3"
#    run "chown -R apache:apache #{release_path}"
#    run "chmod a+rw #{release_path}/log/*"
  end
  
  desc "install any gem dependencies"
  task :install_gems, :role => :app do 
    rails_env = fetch(:rails_env, RAILS_ENV)
    run "cd #{release_path}; rake gems:install RAILS_ENV=#{rails_env}"
  end
end

after :deploy, :seed
desc "seed. for seed-fu"
task :seed, :roles => :db, :only => {:primary => true} do 
  rails_env = fetch(:rails_env, RAILS_ENV)
  run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
end