class ServicesController < ApplicationController
  def show
    @service = Service.find(params[:id])
    add_breadcrumb @service.name, 'service'
  end

  def index
    add_breadcrumb 'Services List'
    @services = Service.all
  end

  def new
    @service = Service.new(:name => "my awesome service")
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      flash[:success] = "Service saved."
      redirect_via_turbolinks_to(service_path(@service))
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_via_turbolinks_to(:back)
    end
  end

  def edit
    @service = Service.find(params[:id])
  end

  def update
    @service = Service.find(params[:id])
    if @service.update!(service_params)
      flash[:success] = "Service updated."
    else
      flash[:warn] = 'Something went wrong while updating Service.'
    end
    # redirect_to :back
    redirect_via_turbolinks_to(:back)
  end

  private
  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def service_params
    params.require(:service).permit(:name, :description, :daemon_name, :init_name, :systemd_name)
  end

end
