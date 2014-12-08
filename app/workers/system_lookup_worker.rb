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
    logger.info "SystemLookup-#{system_lookup.id} for System-#{system_lookup.system_id} finished"
    system = system_lookup.system
    begin
      if SshAutomagick::ssh_login_possible?(system)
        logger.info("SSH connect succeeded!")
        # ohai return json on success
        text_result = SshAutomagick::run_ohai!(system)
        json_result = text_result.is_json? ? text_result : text_result.to_json
        system_lookup.system_lookup_result.update_attributes(result: json_result)
      end
    rescue Exception => e
      logger.error("SSH failed due to #{e.message.inspect}!")
      system_lookup.system_lookup_result.update_attributes(error: e.message)
    end
    logger.info "SystemLookup-#{system_lookup.id} for System-#{system_lookup.system_id} finished"
  end

end

