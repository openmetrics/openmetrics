class SystemLookupWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  include SshAutomagick

  def perform(system_lookup_id)
    sl = SystemLookup.find(system_lookup_id)
    s = sl.system
    sl.update_attributes(started_at: Time.now)
    sl.update_attributes(status: EXECUTION_STATUS.key('started'))
    scan_system(sl)
    sl.update_attributes(finished_at: Time.now)
    sl.update_attributes(status: EXECUTION_STATUS.key('finished'))
  end

  # starts ohai lookup on system(s) with associated IP address
  def scan_system(system_lookup)
    system = system_lookup.system
    if SshAutomagick::ssh_login_possible?(system)
      logger.info("SSH connect succeeded!")
    else
      logger.error("SSH connect failed!")
    end
    logger.info "SystemLookup-#{system_lookup.id} finished"
  end

end

