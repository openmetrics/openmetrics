require 'sidekiq/api' # admin

class WelcomePageController < ApplicationController
  def display
    add_breadcrumb 'Home'
    @user = current_user
  end

  def admin
    sorted_env_vars = Hash[ENV.sort]
    @om_env_vars = sorted_env_vars.reject{|key, value| !key.starts_with? 'OM_'}
  end

end
