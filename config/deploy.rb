require 'vendor/plugins/thinking-sphinx/lib/thinking_sphinx/deploy/capistrano'
load 'lib/testjour.rb'
load 'lib/deploy_app.rb'
load 'lib/deploy_jobs.rb'

set :application, "openphin"
set :repository,  "git://github.com/talho/openphin.git"
set :rails_env, 'production'
set :scm, :git  # override default of subversion
set :branch, 'master'
set :use_sudo, false
set :user, 'apache'
set :git_enable_submodules, true
set :ssh_options, {:forward_agent => true}
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

# Unicorn configuration
set :unicorn_binary, "~/.rvm/gems/ree-1.8.7-2010.02/bin/unicorn"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

task :production do
	role :app, "newtxphin.texashan.org"
	role :web, "newtxphin.texashan.org"
	role :db,  "newtxphin.texashan.org", :primary => true
end

task :staging do
	role :app, "staging.txphin.org"
	role :web, "staging.txphin.org"
	role :jobs, "staging.txphin.org"
	role :db,  "staging.txphin.org", :primary => true
end
 
desc "unicorn restart"
  namespace :deploy do
  task :restart do
    #run "touch #{current_path}/tmp/restart.txt"
		run "kill -s USR2 `cat #{unicorn_pid}`"
  end
end

after 'deploy:update_code', 'deploy:symlink_configs'
after 'deploy:update_code', 'deploy:install_gems'
#after 'deploy:install_gems', 'deploy:restart_backgroundrb'
after "deploy", "deploy:cleanup"
namespace :deploy do
  desc "we need a database. this helps with that."
  task :symlink_configs do
    rails_env = fetch(:rails_env, RAILS_ENV)
    #run "mv #{release_path}/config/database.yml.example #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/#{RAILS_ENV}.sqlite3 #{release_path}/db/#{RAILS_ENV}.sqlite3"
    run "ln -fs #{shared_path}/smtp.rb #{release_path}/config/initializers/smtp.rb"
    run "ln -fs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/sphinx #{release_path}/db/sphinx"
    run "ln -fs #{shared_path}/backgroundrb.yml #{release_path}/config/backgroundrb.yml"
    run "ln -fs #{shared_path}/swn.yml #{release_path}/config/swn.yml"
    run "ln -fs #{shared_path}/email.yml #{release_path}/config/email.yml"
    run "ln -fs #{shared_path}/phone.yml #{release_path}/config/phone.yml"
    run "ln -fs #{shared_path}/system.yml #{release_path}/config/system.yml"
    run "ln -fs #{shared_path}/phin_ms_queues #{release_path}/tmp/phin_ms_queues"
    run "ln -fs #{shared_path}/rollcall #{release_path}/tmp/rollcall"
    run "ln -fs #{shared_path}/sphinx.yml #{release_path}/config/sphinx.yml"
    run "ln -fs #{shared_path}/testjour.yml #{release_path}/config/testjour.yml"
    run "ln -fs #{shared_path}/tutorials #{release_path}/public/tutorials"
    run "ln -fs #{shared_path}/attachments #{release_path}/attachments"
    # for the rollcall plugin
    run "ln -fs #{release_path}/vendor/plugins/rollcall/lib/workers #{release_path}/lib/workers/rollcall"
    run "ln -fs #{release_path}/spec/spec_helper.rb #{release_path}/vendor/plugins/rollcall/spec/spec_helper.rb"
    run "ln -fs #{release_path}/vendor/plugins/rollcall/public/javascript #{release_path}/public/javascripts/rollcall"
    run "ln -fs #{release_path}/vendor/plugins/rollcall/public/stylesheets #{release_path}/public/stylesheets/rollcall"

    run "cd #{release_path}/vendor/plugins/rollcall; git submodule update -i"

    run "ln -fs #{shared_path}/vendor/cache #{release_path}/vendor/cache"
    run "cd #{release_path}; bundle install --without=test --without=cucumber --without=tools"
    if rails_env == 'test'|| rails_env == 'development' || rails_env == "cucumber"
      FileUtils.cp("config/backgroundrb.yml.example", "config/backgroundrb.yml") unless File.exist?("config/backgroundrb.yml")
      FileUtils.cp("config/system.yml.example", "config/system.yml") unless File.exist?("config/system.yml")
#      FileUtils.cp("config/phone.yml.example", "config/phone.yml") unless File.exist?("config/phone.yml")
#      FileUtils.cp("config/swn.yml.example", "config/swn.yml") unless File.exist?("config/swn.yml")
    end
  end

  desc "install any gem dependencies"
  task :install_gems, :role => :app do 
    rails_env = fetch(:rails_env, RAILS_ENV)
    run "cd #{release_path}; rake gems:install RAILS_ENV=#{rails_env}"
  end

namespace :deploy do
  # Overriding the built-in task to add our rollback actions
  task :default, :roles => [:app, :web, :jobs] do
    transaction {
      on_rollback do
        puts "  PERFORMING ROLLBACK, restarting jobs daemons"
        find_and_execute_task("backgroundrb:restart")
        find_and_execute_task("delayed_job:restart")
        puts "  END ROLLBACK"
      end
      update
      restart
    }
  end

  desc "unicorn restart"
  task :restart, :roles => [:app, :web] do 
    begin
      run "kill -s USR2 `cat #{unicorn_pid}`"
    rescue Capistrano::CommandError => e
      puts "Rescue: #{e.class} #{e.message}"
      puts "Rescue: It appears that unicorn is not running, starting ..."
      run "sh #{release_path}/config/kill_server_processes unicorn"
      run "cd #{release_path}; #{unicorn_binary} --daemonize --env production -c #{unicorn_config}"
    end
  end
end

after 'deploy:migrations', :seed
desc "seed. for seed-fu"
task :seed, :roles => :db, :only => {:primary => true} do 
  run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
end

# useful for testing on_rollback actions
task :raise_exc do
  raise "STOP STOP STOP"
end

set :pivotal_tracker_project_id, 19881
set :pivotal_tracker_token, '55a509fe5dfcd133b30ee38367acebfa'

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
