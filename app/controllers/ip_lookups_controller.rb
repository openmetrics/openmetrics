class IpLookupsController < ApplicationController
  def show
    @ip_lookup = IpLookup.find(params[:id])
  end
end
