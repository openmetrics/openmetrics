class SystemsController < ApplicationController
  def index
    @systems = System.all
    respond_with(@systems)
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
