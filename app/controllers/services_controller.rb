class ServicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @service = Service.find(params[:id])
  end
  
  def index
    @services = Service.all
    respond_with(@services)
  end

  def new
    # passing to new causes formbakery placeholders to appear
    @service = Service.new(:name => "my awesome service")
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      flash[:success] = "Service saved."
      redirect_to services_path
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_to_anchor_or_back
    end
  end

  private
  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def service_params
    params.require(:service).permit(:name)
  end

end
