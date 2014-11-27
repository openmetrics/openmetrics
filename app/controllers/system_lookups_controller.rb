class SystemLookupsController < ApplicationController
  def show
    @system_lookup = SystemLookup.find(params[:id])
  end
end
