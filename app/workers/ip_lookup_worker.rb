require 'nmap/parser' # http://rubynmap.sourceforge.net/doc/Nmap/Parser.html

class IpLookupWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(ip_lookup_id)
    i = IpLookup.find(ip_lookup_id)
    i.update_attributes(started_at: Time.now)
    i.update_attributes(status: EXECUTION_STATUS.key('started'))
    scan_services(i)
    i.update_attributes(finished_at: Time.now)
    i.update_attributes(status: EXECUTION_STATUS.key('finished'))
  end

  # executes a bunch of tests with nmap on a given IPv4 adress
  # TODO scan by SSH, if there is a RunningService "SshService" on that ip
  def scan_services(i)
    ip = i.target
    # FIXME cleanup created cachefiles
    # FIXME add error handling for mktemp
    # create nmap xml report by system call
    logger.info "starting nmap service scan on #{ip}"
    tmpfile = ` mktemp --tmpdir=#{Rails.root}/tmp/cache nmap-ip-lookup.xml.XXXXXXXX `
    # FIXME sanatize user input; an attacker could pass somthing like " && rm -rf / here" !!!
    nmap_output = ` nmap -oX "#{tmpfile}" -sCV "#{ip}" `
    logger.debug "Full nmap output:\n#{nmap_output}"

    result = []
    # parallel parsing of scan result, save scanresult as IpLookupResult
    callback = proc do |host|
      return if host.status != "up"
      logger.info "scanresult for #{host.addr}"
      [:tcp, :udp].each do |type|
        host.getports(type, "open") do |port|
          srv = port.service
          result.push({:addr => host.addr, :port => port, :hostnames => host.hostname, :services => srv})
          logger.info "Port ##{port.num}/#{port.proto} is open (#{port.reason})"
          logger.info "\tService: #{srv.name}" if srv.name
          logger.info "\tProduct: #{srv.product}" if srv.product
          logger.info "\tVersion: #{srv.version}" if srv.version
        end
      end
    end
    parser = Nmap::Parser.new(:callback => callback)
    if parser.parsefile(tmpfile)
      if result.empty?
        i.ip_lookup_result.update_attributes(result: 'host is down'.to_json)
      else
        i.ip_lookup_result.update_attributes(result: result.to_json)
      end

    end
    logger.info "scan on #{ip} finished in #{parser.session.scan_time} sec"
  end

end

