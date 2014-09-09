source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.3'

# we want to have user sessions (breadcrumbs et al.)
gem 'activerecord-session_store'

# WEBrick sucks, use Puma as default webserver
gem 'puma'

# Use postgres as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# pin sprockets to specific version due to bug??
# otherwise adding 'sass-rails' gem failed with:
# ActionView::Template::Error (undefined method `environment' for nil:NilClass
gem 'sprockets', '2.11.0'


# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.1'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
#gem 'jquery-turbolinks'

# better flash notifications
gem 'unobtrusive_flash', '>=3'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# use sidekiq as for background processing
gem 'sidekiq'

# read and write to Round-Robin-Databases (.rrd)
gem 'rrd-ffi'

# needed for sidekiq monitoring web mount
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil

# nmap for system lookups
gem 'nmap-parser', '~> 0.3.5'

# some net magick
gem 'net-ssh'
gem 'net-sftp'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Devise for authentication https://github.com/plataformatec/devise
gem 'devise'

# that tiny images from gravatar https://github.com/mdeering/gravatar_image_tag
gem 'gravatar_image_tag'

# js translations https://github.com/fnando/i18n-js
# original gem is not compatible with Rails4 yet
#gem 'i18n-js'
gem "i18n-js-pika", require: "i18n-js", ref: "rails4"

# provides `i18n-tasks' command to find and fix missing translations, https://github.com/glebm/i18n-tasks
gem 'i18n-tasks', '~> 0.3.9'

# xlsx spreadsheet export; required by `i18n-tasks xlsx-report` command
gem 'axlsx', '~> 2.0'

# use selenium webdriver for automated webtests
gem 'selenium-webdriver', '~> 2.41.0'
group :development do
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
end

# synthax highlight
gem 'RedCloth', :require => 'redcloth'
gem 'coderay', :require => ['coderay', 'coderay/for_redcloth']

# https://github.com/codykrieger/ace-rails-ap for code edit textarea
gem 'ace-rails-ap'

# fileupload
gem 'paperclip', "~> 4.1"
gem 'jquery-fileupload-rails'

# nice urls https://github.com/norman/friendly_id
gem 'friendly_id', '~> 5.0.0'

# track model changes https://github.com/SCPR/secretary-rails
gem 'secretary-rails'

# strip whitespaces for model attributes
gem 'strip_attributes'

# activity feed https://github.com/pokonski/public_activity
#gem 'public_activity'
gem 'public_activity', github: 'pokonski/public_activity' # we need :fallback partial support see https://github.com/pokonski/public_activity/issues/150

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
gem 'debugger', group: [:development, :test]
