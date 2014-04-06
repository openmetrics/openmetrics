class SystemsController < ApplicationController
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
      redirect_to systems_path
    else
      redirect_to new_system_path
    end
  end

  # POST /systems/scan
  # initiates background process IpLookupWorker to start nmap scan on given target
  # creates an IpLookup object when finished for further use
  def scan
    i = IpLookup.new(ip_lookup_params)
    i.user_id = current_user.id
    i.job_id = IpLookupWorker.perform_async(i.target)
    if i.save
      flash[:success] = "IpLookup scheduled successfully. You will be noticed as soon as scanresult is available."
      redirect_to :back
    else
      flash[:warn] = "That IpLookup didn't work."
      redirect_to :back
    end

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
