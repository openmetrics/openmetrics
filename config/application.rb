require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

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
      #{config.root}/lib/ssh_automagick
      #{config.root}/lib/webtest_automagick
      #{config.root}/lib/html_tablebakery
      #{config.root}/lib/html_formbakery
    )

    # dont load all the helpers all the time
    config.action_controller.include_all_helpers = false

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Europe/Berlin'

    # The default locale is :de and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = false
    config.i18n.load_path += Dir[Rails.root.join('locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # automatically generate translations by the I18n::JS::Middleware.
    # https://github.com/PikachuEXE/i18n-js
    config.middleware.use I18n::JS::Middleware

    # http://stackoverflow.com/questions/19042525/heroku-assets-precompile-fails-for-i18n-js
    config.assets.version = '1.0'

    # make rake assets:precompile happy
    # otherwise "Cannot precompile i18n-js translations unless environment is initialized."
    config.assets.initialize_on_precompile = false

    # Precompile *all* assets, except those that start with underscore
    #config.assets.precompile << /(^[^_\/]|\/[^_])[^\/]*$/

    # via https://github.com/sstephenson/sprockets/issues/347#issuecomment-25543201
    # We don't want the default of everything that isn't js or css, because it pulls too many things in
    config.assets.precompile.shift

    # Explicitly register the extensions we are interested in compiling
    config.assets.precompile << Proc.new { |path|

      # skip scss files beginning with underscore
      false if (File.basename(path).starts_with?('_') and File.basename(path).ends_with?('.scss'))

      # include the usual files
      File.extname(path).in? [
                                '.html', '.erb', '.haml', '.css',  # Templates
                                '.png',  '.gif', '.jpg', '.jpeg', '.svg', '.ico', # Images
                                '.eot',  '.otf', '.svc', '.woff', '.ttf', # Fonts
                            ]
   }


    # load rails env into sidekiq
    #config.eager_load_paths += ["#{config.root}/lib/workers"]
  end
end
