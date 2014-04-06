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
    @system = System.new(params[:system])
    if @system.save
      redirect_to @system
    else
      render new
    end
  end

  # initiates background process IpLookupWorker to start nmap scan on given target
  # creates an IpLookup object when finished for further use
  def scan
    target = params[:target]
    i = IpLookup.new
    i.user_id = current_user.id
    i.target = target
    i.job_id = IpLookupWorker.perform_async(target)
    i.save
  end

end
