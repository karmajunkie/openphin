# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures
Cucumber::Rails.bypass_rescue # Comment out this line if you want Rails own error handling 
                              # (e.g. rescue_action_in_public / rescue_responses / rescue_from)

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end

require 'cucumber/rails/rspec'
require 'webrat/core/matchers'

require "#{Rails.root}/spec/factories"

Before do
  # Clear out PHIN_MS queue
  FileUtils.remove_dir(Agency[:phin_ms_base_path], true)
end