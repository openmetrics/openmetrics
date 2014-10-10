require 'sidekiq/api' # admin
require 'uri' # admin
require 'net/http' # admin

class WelcomePageController < ApplicationController
  def display
    @recent_events = PublicActivity::Activity.order('created_at desc').limit(15)
    @user = current_user
    add_breadcrumb 'Home'
  end

  def admin
    sorted_env_vars = Hash[ENV.sort]
    @om_env_vars = sorted_env_vars.reject{|key, value| !key.starts_with? 'OM_'}


    # fetch selenium status by http (returns json)
    uri = URI("http://localhost:5555/wd/hub/status")
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl = false
    headers = Hash.new
    headers['Content-Type'] = 'application/json'
    request = Net::HTTP::Get.new(uri.request_uri, headers)
    begin
      response = conn.request(request)
      @selenium_hub_status =  if response.kind_of? Net::HTTPSuccess
                                #JSON.parse(response.body)
                                response.body
                              else
                                logger.error "Error while fetching selenium hub status! Response: #{response.inspect}"
                                nil
                              end
    rescue
      @selenium_hub_status = "Failed to connect to #{uri.to_s}! Selenium hub may be down."
    end

  end

end
