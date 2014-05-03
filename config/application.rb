require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Openmetrics
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # load services types
    config.autoload_paths += %W(#{config.root}/app/models/services)

    config.eager_load_paths += %W(
      #{config.root}/lib/html_tablebakery
      #{config.root}/lib/html_formbakery
    )

    # dont load all the helpers all the time
    config.action_controller.include_all_helpers = false

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Berlin'

    # The default locale is :de and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # automatically generate translations by the I18n::JS::Middleware.
    # https://github.com/PikachuEXE/i18n-js
    config.middleware.use I18n::JS::Middleware

    # http://stackoverflow.com/questions/19042525/heroku-assets-precompile-fails-for-i18n-js
    config.assets.version = '1.0'

    # make rake assets:precompile happy
    # otherwise "Cannot precompile i18n-js translations unless environment is initialized."
    config.assets.initialize_on_precompile = true

    # load rails env into sidekiq
    #config.eager_load_paths += ["#{config.root}/lib/workers"]
  end
end
