require 'sidekiq/api' # admin

class WelcomePageController < ApplicationController
  def display
    @recent_events = PublicActivity::Activity.order('created_at desc').limit(15)
    @user = current_user
    add_breadcrumb 'Home'
  end

  def admin
    sorted_env_vars = Hash[ENV.sort]
    @om_env_vars = sorted_env_vars.reject{|key, value| !key.starts_with? 'OM_'}
  end

end
