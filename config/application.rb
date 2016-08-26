require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
Bundler.require(*Rails.groups)

module Guardian
  class Application < Rails::Application
    # Disable most generators
    config.generators do |g|
      g.orm             :active_record
      g.test_framework  false
      g.stylesheets     false
      g.javascripts     false
      g.helper          false
    end

    # Include from lib
    config.eager_load_paths += %W(#{config.root}/lib)

    # Disable field_with_errors
    config.action_view.field_error_proc = Proc.new { |t, i| t }
  end
end
