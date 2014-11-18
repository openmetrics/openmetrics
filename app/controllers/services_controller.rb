class ServicesController < ApplicationController
  before_filter :get_object, only: [:show, :edit, :update, :destroy]

  def show
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
      @service.create_activity :create, :owner => current_user
      flash[:success] = "Service saved."
      redirect_via_turbolinks_to(service_path(@service))
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_via_turbolinks_to(:back)
    end
  end

  def edit
  end

  def update
    if @service.update!(service_params)
      @service.create_activity :update, :owner => current_user
      flash[:success] = "Service updated."
    else
      flash[:warn] = 'Something went wrong while updating Service.'
    end
    # redirect_to :back
    redirect_via_turbolinks_to(:back)
  end

  def destroy
    if @service.destroy
      flash[:notice] = "Successfully destroyed service."
      redirect_to :action => "index"
    else
      flash[:error] = 'Failed to delete service.'
    end
  end

  private

  def get_object
    @service = Service.find(params[:id])
  end

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def service_params
    params.require(:service).permit(:name, :description, :daemon_name, :init_name, :systemd_name)
  end

end
