class SystemsController < ApplicationController

  def index
    add_breadcrumb 'Systems'
    @systems = System.includes(:running_services)
    respond_with(@systems)
  end

  def new
    # passing to new causes formbakery placeholders to appear
    @system = System.new(name: 'my example host', fqdn: 'host.example.com')
    @ip_lookup = IpLookup.new(:target => 'www.example.com or 127.0.0.1/32')
    @recent_ip_lookups = IpLookup.recent.where(user: current_user)
  end

  def create
    @system = System.new(system_params)
    if @system.save
      @system.create_activity :create, :owner => current_user
      flash[:success] = "System saved."
      redirect_to systems_path
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_to_anchor_or_back
    end
  end

  # POST /systems/scan
  # initiates background process IpLookupWorker to start nmap scan on given target
  # creates an IpLookup object when finished for further use
  def scan
    i = IpLookup.new(ip_lookup_params)
    i.user_id = current_user.id
    begin
      if i.save
        i.create_activity :create, :owner => current_user
        flash[:success] = 'IpLookup scheduled successfully.'
      else
        flash[:warn] = 'Oh snap! Scheduling IpLookup on that target failed. ;('
      end
    rescue
      logger.error 'Failed to schedule job on IpLookupWorker'
      flash[:error] = "That IpLookup schedule didn't work."
    ensure
      redirect_to_anchor_or_back
    end
  end

  def show
    @system = System.friendly.find(params[:id])
    add_breadcrumb @system.name, 'system'
  end

  def edit
    @system = System.friendly.find(params[:id])
    add_breadcrumb "edit #{@system.name}", "system"
    @services = Service.all
  end

  def update
    @system = System.friendly.find(params[:id])
    if @system.update!(system_params)
      @system.create_activity :update, :owner => current_user
      flash[:success] = "System updated."
    else
      flash[:warn] = 'Something went wrong while updating system.'
    end
    redirect_to :back
  end

  private
  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def system_params
    params.require(:system).permit(:name, :fqdn)
  end

  def ip_lookup_params
    params.require(:ip_lookup).permit(:target)
  end

end
