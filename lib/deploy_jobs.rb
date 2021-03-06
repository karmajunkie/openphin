namespace :sphinx do
  desc "start sphinx if not running"
  task :start_if_not, :roles => :jobs do
    # only start if no sphinx process are running
    cmd = "cd #{current_path};"
    cmd += '[[ -n "$(ps -ef | grep sphinx | grep -v grep)" ]] || '
    cmd += "(rake ts:index RAILS_ENV=#{rails_env} && "
    cmd += "rake ts:start RAILS_ENV=#{rails_env})"
    run cmd
  end

  desc "stop, index and then start sphinx"
  task :rebuild, :roles => :jobs do
    begin
      run "cd #{previous_release}; rake ts:stop RAILS_ENV=#{rails_env}"
    rescue Capistrano::CommandError => e
      puts "Rescue: #{e.class} #{e.message}"
      puts "Rescue: sphinx stop failed, ignoring ..."
    end
    run "cd #{current_path}; rake ts:index RAILS_ENV=#{rails_env}"
    run "cd #{current_path}; rake ts:start RAILS_ENV=#{rails_env}"
  end
end

namespace :delayed_job do
  desc "Stop the delayed_job process"
  task :stop, :roles => :jobs do
    run "cd #{current_path}; script/delayed_job -e #{rails_env} stop"
  end

  desc "Start the delayed_job process"
  task :start, :roles => :jobs do
    run "cd #{current_path}; script/delayed_job -e #{rails_env} start"
  end

  desc "Restart the delayed_job process"
  task :restart, :roles => :jobs do
    run "cd #{current_path}; script/delayed_job -e #{rails_env} restart"
  end
end

namespace :backgroundrb do
  desc "stop backgroundrb"
  task :stop, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/backgroundrb stop"
  end

  desc "start backgroundrb"
  task :start, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/backgroundrb start"
  end

  desc "restart backgroundrb"
  task :restart, :roles => :jobs do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} script/backgroundrb restart"
  end
end
