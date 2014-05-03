class IpLookupsController < ApplicationController
  before_action :authenticate_user!

  def show
    @ip_lookup = IpLookup.find(params[:id])
  end
end
