class SystemsController < ApplicationController
  before_action :authenticate_user!

  def index
    @systems = System.all
    respond_with(@systems)
  end

  def new
    # passing to new causes formbakery placeholders to appear
    @system = System.new(:name => "my example host", :fqdn => "host.example.com")
    @ip_lookup = IpLookup.new(:target => "www.example.com or 127.0.0.1/32")
  end

  def create
    @system = System.new(system_params)
    if @system.save
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
      # try to perform async, otherwise fail
      i.job_id = IpLookupWorker.perform_async(i.target)
      if i.save
        flash[:success] = "IpLookup scheduled successfully. You will be noticed as soon as scanresult is available."
      else
        flash[:warn] = "Oh snap! Scheduling IpLookup on that target failed. ;("
      end
    rescue
      logger.error "Failed to schedule job on IpLookupWorker"
      flash[:error] = "That IpLookup schedule didn't work."
    ensure
      redirect_to_anchor_or_back
    end
  end

  def show
    @system = System.find(params[:id])
  end

  def edit
    @system = System.find(params[:id])
  end

  private
  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def system_params
    params.require(:system).permit(:name, :fqdn, :title)
  end

  def ip_lookup_params
    params.require(:ip_lookup).permit(:target)
  end

end
