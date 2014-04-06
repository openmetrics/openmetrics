class SystemsController < ApplicationController
  def index
    @systems = System.all
    respond_with(@systems)
  end

  def new
    # passing to new causes placeholders to appear
    @system = System.new(:name => "New systems name", :fqdn => "host.example.com")
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
