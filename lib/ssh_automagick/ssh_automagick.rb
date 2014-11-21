require 'net/ssh' #this is the whole magic!
#require 'net/scp' #use sftp instead
require 'net/sftp'

module SshAutomagick


   public

   # Writes collectd_plugin.configuration into a file in local filesystem,
   # substitues variables & transfers it to remote server.
   # FIXME add error handling http://ianpurton.com/ruby-ssh-example-with-error-handling
   def self.enable_collectd_plugin(collectd_plugin, system)
     system_ip = system.cidr
     system_sshuser = system.sshuser
     # FIXME hardcoded path to remotes host plugin dir
     configdir = '/opt/openmetrics/om-agent/etc/collectd/plugins.d'
     configfile = "om-" + collectd_plugin.id.to_s + ".conf"
     remotefile = "#{configdir}/#{configfile}"
#     tmpfile = `mktemp --tmpdir=/tmp #{configfile}.XXXXXX`
     tmpfile = `mktemp -p /tmp #{configfile}.XXXXXX`
     stdout = "" #initialize as string to avoid returning NIL

     # 1) prepare tempfile of collectd_plugin.configuration
     # FIXME error detection if tmpfile returns nothing/error/nil/etc
     File.open(tmpfile, 'w') { |f| f.puts(collectd_plugin.configuration) }

     # substitute system variables
     # "${varname}" comes from system_variables
     # "${ATTR:name} comes from system attribute
     # TODO "${ENV:name} should come from systems environment
     system_variables = SystemVariable.where(system_id: system.id)
     text = File.read(tmpfile)
     system_variables.each { |sv|
      text.gsub!(/\$\{#{sv.name}\}/, "#{sv.value}")
     }
     attributes = text.scan(/\$\{ATTR:(.+)\}/)
     attributes.each do |attr|
       #logger.debug "substiting #{attr}"
       method = attr.to_s
       replace = eval("system.#{method}") if system.attributes.include?(method)
       text.gsub!(/\$\{ATTR:#{attr}\}/, "#{replace}")
     end
     #logger.debug "#{text}"
     File.open(tmpfile, 'w') { |f| f.write(text) }

     keys = '/home/om/.ssh/id_rsa_om'
     # :use_agent needs to be false, otherwise :keys are ignored due to bug https://github.com/net-ssh/net-ssh/issues/137
     Net::SSH.start(system_ip, system_sshuser, :keys => keys) do |ssh|
	       if create_collectd_config_backup(ssh, remotefile) != 0
         # scp over existing ssh connection doesn't work, dunno why
         # ssh.scp.upload! "#{tmpfile}", "#{remotefile}" should do the trick, but it just blocks
         Net::SFTP.start(system_ip, system_sshuser, :keys => keys) do |sftp|
          sftp.upload!("#{tmpfile}", "#{remotefile}")
         end
       end       


       # 3) restart remote collectd client
       # FIXME hardcoded path to start/stop script
       puts "INFO restarting collectd daemon on #{system_ip}"
       stdout = ssh.exec!("/opt/openmetrics/om-agent/scripts/rc.collectd restart")
       return stdout
     end # Net:SSH block 
   end

   # reomves collectd_plugin.configuration remote server, backup files are
   # not deleted
   def self.disable_collectd_plugin(collectd_plugin, system)
      system_ip = system.ip
      system_sshuser = system.sshuser
      # FIXME hardcoded path to remotes host plugin dir
      configdir = '/opt/openmetrics/om-agent/etc/collectd/plugins.d'
      configfile = "om-" + collectd_plugin.id.to_s + ".conf"
      remotefile = "#{configdir}/#{configfile}"
      stdout = ""
      puts "INFO removing #{remotefile} on #{system_ip}"
      Net::SSH.start(system_ip, system_sshuser) do |ssh|
        ssh.exec!("rm -f #{remotefile}")
        # FIXME hardcoded path to start/stop script
        puts "INFO restarting collectd daemon on #{system_ip}"
        stdout = ssh.exec!("/opt/openmetrics/om-agent/scripts/rc.collectd restart")
        return stdout
      end  
   end

   # This will cause SSHAutomagick to login via SSH on the given remote server
   # if there is already a SSHAutomagick pubkey on this machine.
   #
   # Then it will read the current authenticated_users file and
   # report it back to the application
   #
   def self.read_current_keys(system_ip)
     stdout = "" #initialize as string to avoid returning NIL
     Net::SSH.start(system_ip, 'mgrobelin') do |ssh|
        stdout = ssh.exec!("cat .ssh/authorized_keys")
      end
      return stdout
   end

   # Given the result of read_current_keys, or the string representation of a
   # authorized users file, this methed returns an array with the keydata as Hash.
   #
   def self.parse_authorized_keys(authorized_keys)
     result = []
     #puts "!A!"
     unless authorized_keys.blank?
       #puts "!B!"
       
       
       authorized_keys.each_line do |line|
         #puts "LINE!"

         # we need to parse our keyfile a little
         # we do this with regular expressions
         
         k1 = line[line.index(/ssh-... .*== .*/)..line.length]
         
         # options
         k0 = ""
         if line =~ /..*ssh-... .*== .*/ # line actually contains options
           k0 = line[0..line.index(/ssh-... .*== .*/)-1]
         end
         
         k2 = k1[k1.index(/== .*/)..k1.length]
         
         # comment
         k2b = k2[3..k2.length-1] # '-1' to exclude line feed '\n'
         
         # keyonly (no options, no comment)
         k3 = k1[k1.index(/ssh-... .*/)..k1.index(/== .*/)] 
         
         
         # WARNING: line must be clean and sanitized for this!
         # this should be done by the key manager.
         # 
         # create a random 4 character BASE-16 hash to avoid collisions between
         # clustered processes
         hash=((rand * 65535)).to_i.to_s(16).upcase.rjust(4,'0')
         
         # SYSCALL!! (FIXME Later use mktemp for this, and place before keystring parsing)
       s = %x[echo "#{line}" > /tmp/omtmpkey#{hash} && ssh-keygen -l -f /tmp/omtmpkey#{hash} && rm /tmp/omtmpkey#{hash}]
         # ---------

         
         if s.include? "not a public key file."
           check_bits = "INVALID KEY!"
         else check_bits = s[0..3] end

         # key-type
         k4 = k3[0..6]
         
         keydata = {} # new Hash
         
         keydata[:options] = k0
         keydata[:keytype] = k4 # ssh-rsa normally
         keydata[:key]     = k3 # the lone key-data
         keydata[:bitsize] = check_bits
         keydata[:comment] = k2b # usually the username
         
         result << keydata
         #puts keydata.inspect
         #puts @result.class
       end
       
       return result
     else
       return nil
       #puts "!CCC!"
     end
   end

  # Check login via SSH on the given remote server
  def self.ssh_login_possible?(system)
    keys = '~/.ssh/id_rsa_om'
    # :use_agent needs to be false, otherwise :keys are ignored due to bug https://github.com/net-ssh/net-ssh/issues/137
    Net::SSH.start(system.cidr, system.sshuser, :keys => keys) do |ssh|
      test_ssh_connection(ssh)
    end
  end


   # This will cause SSHAutomagick to login via SSH on the given remote server
   # if there is already a SSHAutomagick pubkey on this machine.
   #
   # Then it will try to deploy the given pubkey (including comments and commands!)
   # on the machine.
   #
   # Before doing so it will check if the given is already present on the machine.
   # If the key is present on the machine SSHAutomagick will NOT deploy the new
   # key.
   #
   def self.deploy_key(system_ip, pubkey)

     return "Malformed pubkey, deploykey aborted!" unless pubkey_format_ok?(pubkey)

     Net::SSH.start(system_ip, 'mgrobelin') do |ssh|
       
       stdout = ""
       
       if token_present(ssh) != 0
         # Already someone on the machine, do nothing
         # TODO: behave more graceful here
         return "KEYFILE BLOCKED!"
       end
   
       if key_present(ssh, pubkey)
         
         # key is present, nothing to do, remove our TOKEN, leave
         remove_token(ssh)
         return "key already in place!"

       else

         # The key is not present, therefore we can place it
         # but we need a backup of authorized_key first!
         create_backup(ssh)

         # insert new key
         stdout = ssh.exec!("ssh localhost \"echo \"#{pubkey}\" >> .ssh/authorized_keys\"")

         # done
         remove_token(ssh)
         return "key installed!"  # TODO: make this a real check!
         
       end
      
     end # Net:SSH block

   end 


   # This will cause SSHAutomagick to login on the given remote server if there
   # already is a SSHAutomagick pubkey on the machine.
   #
   # SSHAutomagick will then delete the given pubkey from the authenticated_users
   # without caring about comments or commands.
   #
   # NOTE: SSHAutomagick will delete the key entirely from the authenticated_users file,
   # should the key exist more than once within it.
   #
   def remove_key(system_ip, pubkey)

     return "Malformed pubkey, removekey aborted!" unless pubkey_format_ok?(pubkey)

     puts "REMOVEKEY REMOVEKEY REMOVEKEY REMOVEKEY REMOVEKEY"
     Net::SSH.start(system_ip, 'mgrobelin') do |ssh|

       stdout = ""

       if token_present(ssh) != 0
         # TODO: behave gracefully here
         return "KEYFILE BLOCKED!"
       end
       
       if key_present(ssh, pubkey)

         create_backup(ssh)

         # remove key
         stdout = ssh.exec!("sed -e \"/`echo \\\"#{pubkey}\\\" | sed \\\"s/^.* ssh-/ssh-/g\\\" | sed \\\"s/==.*/==/g\\\"`/d\" -i .ssh/authorized_keys")
         
         # done
         remove_token(ssh)
         return "key removed!"

       else
 
         return "unable to remove key, because the key was not found"

       end
       
     end # Net:SSH block

   end

   def self.run_ohai!(system)
     keys = '~/.ssh/id_rsa_om'
     out = ''
     Net::SSH.start(system.cidr, system.sshuser, :keys => keys) do |ssh|
       ssh.exec!('. ~/.profile && cd /opt/openmetrics/om-agent/lib/ohai && ./bin/ohai') do |channel, stream, data|
         out << data
       end
     end
     out
   end



   protected

   # Creates a backup of the collectd plugin config file
   #
   # schema: <remotefile>.conf.bak.YYYY-MM-DD_HH:MM_XXXX
   #
   def self.create_collectd_config_backup(ssh_connection, filepath)
         # create a random 4 character BASE-16 hash
         hash=((rand * 65535)).to_i.to_s(16).upcase.rjust(4,'0')

         # copy and create backup;
         # TODO echo $? returns exit code of previous command - is this needed?
         ssh_connection.exec!("cp -a #{filepath} #{filepath}.bak.`date +%Y-%m-%d_%H:%M`_#{hash} ; echo $?")
   end


   # Checks with the current ssh-session, if there is a token present that
   # defines the authorized_keys file as 'in-use'.
   #
   # If a token is present its age will be returned as float
   #
   # If there is no Token the float will be 0
   #
   def self.token_present(ssh_connection)
     stdout = ""
     ssh_connection.exec!("if [ -f .ssh/TOKEN ];then echo 'TOKEN';else touch .ssh/TOKEN;fi") do |channel, stream, data|
       stdout << data if stream == :stdout
     end
     if stdout.empty?
       # No Token found, created one to lock authorized keys, tagged it with timestamp
       ssh_connection.exec!("echo '#{Time.now.to_f}' > .ssh/TOKEN")
       return 0
     else
       # Token found, do not touch anything

       # get token age
       stdout = ""
       ssh_connection.exec!("cat .ssh/TOKEN") do |channel, stream, data|
          stdout << data if stream == :stdout
       end
       token_age = Time.now.to_f - stdout.to_f
       return token_age
     end
   end

   # Removes the TOKEN from the given ssh_connection and returns its age as float.
   # '0' means that no TOKEN was found.
   #
   def self.remove_token(ssh_connection)
     stdout = ""
     ssh_connection.exec!("if [ -f .ssh/TOKEN ];then echo 'TOKEN';else touch .ssh/TOKEN;fi") do |channel, stream, data|
       stdout << data if stream == :stdout
     end
     if stdout.empty?
       # No Token found, so nothing should be deleted
       return 0
     else
       # Token found, do not touch anything

       # get token age
       stdout = ""
       ssh_connection.exec!("cat .ssh/TOKEN && rm .ssh/TOKEN") do |channel, stream, data|
          stdout << data if stream == :stdout
       end
       token_age = Time.now.to_f - stdout.to_f
       return token_age
     end
   end

   # tries to execute noop-command on given ssh_connection
   #
   def self.test_ssh_connection(ssh_connection)
     stdout = ""
     ssh_connection.exec!(':') do |channel, stream, data|
       stdout << data if stream == :stdout
     end
     stdout.empty? ? true : false
   end

   # Creates a backup of the authorized keys file
   #
   # schema: authorized_keys.bak.YYYY-MM-DD_HH:MM_XXXX
   #
   def self.create_backup(ssh_connection)
         # create a random 4 character BASE-16 hash
         hash=((rand * 65535)).to_i.to_s(16).upcase.rjust(4,'0')

         # copy and create backup
         ssh_connection.exec!("cp .ssh/authorized_keys .ssh/authorized_keys.bak.`date +%Y-%m-%d_%H:%M`_#{hash}")
         ssh_connection.exec!("cp .ssh/authorized_keys .ssh/om_backup") # we dont known the filename for the backup since we use date not ruby
   end

   # Checks if the given pubkey is contained in authorized keys
   # 
   # NOTE: pubkey will be sanitized for the check, so SSHAutomagick will not
   # care about comments or commands, just the plain key.
   #
   def self.key_present(ssh_connection, pubkey)

     stdout=""
     
     stdout = ssh_connection.exec!("grep \"`echo \\\"#{pubkey}\\\" | sed \\\"s/^.* ssh-/ssh-/g\\\" | sed \\\"s/==.*/==/g\\\"`\" ~/.ssh/authorized_keys")
    
      if stdout.nil? or stdout.empty?
        return false # key not present
      end
      return true # key is present
   end

   # This filter tries to check the given SSHPubkey's format to avoid inserting
   # NIL-keys or other seriously malformed keys.
   # 
   # WARNING: This method is not »uberperfect« you still shuold sanitize and check
   # the keys during the initial upload!
   #
   def self.pubkey_format_ok?(pubkey)
     return false if pubkey.nil?
     return false if pubkey.empty?
     return false if pubkey.include? "\n" # pubkey should only be one line!

     return true # pubkey should be okay
   end

end
