ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require_relative '../lib/guardian/config'
Guardian.set_database_url

if Guardian.config.rails && Guardian.config.rails.environment
  ENV['RAILS_ENV'] = Guardian.config.rails.environment
end
