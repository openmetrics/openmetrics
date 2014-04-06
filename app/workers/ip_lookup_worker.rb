require 'nmap/parser' # http://rubynmap.sourceforge.net/doc/Nmap/Parser.html

class IpLookupWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(target)
    scan_services!(target)
  end

  # executes a bunch of tests with nmap on a given IPv4 adress
  # TODO scan by SSH, if there is a RunningService "SshService" on that ip
  def scan_services!(ip)
    # FIXME cleanup created cachefiles
    # FIXME add error handling for mktemp
    # create nmap xml report by system call
    logger.info "starting nmap service scan on #{ip}"
    tmpfile = ` mktemp --tmpdir=#{Rails.root}/tmp/cache nmap-ip-lookup.xml.XXXXXXXX `
    # FIXME sanatize user input; an attacker could pass somthing like " && rm -rf / here" !!!
    nmap_output = ` nmap -oX "#{tmpfile}" -sCV "#{ip}" `
    logger.debug "Full nmap output:\n#{nmap_output}"

    result = []
    # parallel parsing of scan result
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
      i = IpLookup.new
      i.target = ip
      i.job_id = self.jid
      if result.empty?
        i.scanresult = 'host is down'.to_json
      else
        i.scanresult = result.to_json
      end
      i.save

    end
    #process_result
    logger.info "scan on #{ip} finished in #{parser.session.scan_time} sec"
  end

  # TODO add RunningServices, their Service.type could be guessed by camalize nmap output, e.g. http and append "Service"
  # TODO implement Notifications for WEB-UI
  def process_result
    puts "INFO IPLookupWorker starting scan result post processing"

    cache["my_scan_result"] = @result.inspect

    # create an IpLookup
    if @result
      for host in @result
        puts "DEBUG got result #{host.inspect}"
        #puts "INFO creating System for #{host}"
        #s = System.new
        #s.fqdn = host[:hostnames]
        #s.ip = host[:addr]
        #s.description = "added by IpLookupWorker"
        #s.save

      end
    else
      puts "WARN IpLookupWorker failed"
    end

  end

end

