require 'socket'
require File.expand_path('../../rrdtool/rrdtool', __FILE__)

module DataProvider
  module Collectd
    class Provider < RRDTool::Provider
      
      def initialize()
        self.load_plugins(__FILE__)
        @path = "#{ENV['OM_BASE_DIR']}/data/collectd/rrd"
      end


      # connect to collectd socket and use LISTVAL/GETVAL to fetch last value and update time for given identifier
      # echo 'LISTVAL' | socat - UNIX:/opt/openmetrics/run/collectd/collectd-socket
      # echo 'GETVAL "labskaus/swap/swap_io-out"' | socat - UNIX:/opt/openmetrics/run/collectd/collectd-socket
      def get_data_from_socket(identifier)
        hostname = identifier.split('/')[0]
        socket_path = "#{ENV['OM_BASE_DIR']}/run/collectd/collectd-socket"
        last_update = nil

        socket = UNIXSocket.new(socket_path)
        socket.puts("LISTVAL")
        first_line = socket.gets
        num_results = first_line.split(" ").first.to_i
        num_results.times do
          line = socket.gets
          if line.split(' ')[1] == identifier
            last_update = line.split(' ')[0]
          end
        end
        socket.close

        socket = UNIXSocket.new(socket_path)
        socket.puts("GETVAL \"#{identifier}\"") # double quotes for identifiers with whitspace
        first_line = socket.gets
        r = []
        num_datasources = first_line.split(" ").first.to_i
        # identifier: host "/" plugin ["-" plugin instance] "/" type ["-" type instance]
        # knecht.parship.internal/load/load
        # labskaus/df-boot-efi/df_complex-free
        plugin_identifier, type_identifier = identifier.gsub(/#{hostname}\//, '').split("/")
        plugin, plugin_instance = plugin_identifier.match(/^([^-]+)?-?(.*)?$/).captures
        type, type_instance = type_identifier.match(/^([^-]+)?-?(.*)?$/).captures
        num_datasources.times do
          line = socket.gets
          ds = line.split('=')[0]
          value = line.split('=')[1]
          if value =~ /\r?\n$/
            value.gsub!(/\r?\n$/, ''); # remove ending CR and linebreaks
          end
          metric = {}
          metric['identifier'] = identifier
          metric['host'] = hostname
          metric['value'] = value
          metric['last_update'] = last_update
          metric['metric_options'] = {}
          metric['metric_options']['plugin'] = plugin
          metric['metric_options']['plugin_instance'] = plugin_instance
          metric['metric_options']['type'] = type
          metric['metric_options']['type_instance'] = type_instance
          metric['metric_options']['ds'] = ds
          r << metric
        end
        socket.close
        r
      end

      # 1) get all available metrics by socket LISTVAL
      # 2) filter host of interest
      # 3) get datasources by socket GETVAL
      def get_all_metrics_from_socket(hostname)
        socket_path = "#{ENV['OM_BASE_DIR']}/run/collectd/collectd-socket"

        # 1)
        socket = UNIXSocket.new(socket_path)
        socket.puts("LISTVAL")
        first_line = socket.gets
        num_results = first_line.split(" ").first.to_i

        # 2)
        # TODO this isn't really effective as socket.gets will be called num_result times
        metric_list = []
        num_results.times do
          line = socket.gets
          if line =~ /#{hostname}/
            metric_list << line.strip
          end
        end
        socket.close

        # 3) parse socket results https://collectd.org/wiki/index.php/Naming_schema
        r = []
        metric_list.each do |element|
          last_update, identifier  = element.split(" ", 2) # only two splits as the identifier may include whitespaces
          socket = UNIXSocket.new(socket_path)
          socket.puts("GETVAL \"#{identifier}\"") # double quotes for identifiers with whitspace
          first_line = socket.gets
          num_datasources = first_line.split(" ").first.to_i
          # identifier: host "/" plugin ["-" plugin instance] "/" type ["-" type instance]
          # knecht.parship.internal/load/load
          # labskaus/df-boot-efi/df_complex-free
          plugin_identifier, type_identifier = identifier.gsub(/#{hostname}\//, '').split("/")
          plugin, plugin_instance = plugin_identifier.match(/^([^-]+)?-?(.*)?$/).captures
          type, type_instance = type_identifier.match(/^([^-]+)?-?(.*)?$/).captures
          num_datasources.times do
            line = socket.gets
            ds = line.split('=')[0]
            value = line.split('=')[1]
            if value =~ /\r?\n$/
              value.gsub!(/\r?\n$/, ''); # remove ending CR and linebreaks
            end
            metric = {}
            metric['identifier'] = identifier
            metric['host'] = hostname
            metric['last_update'] = last_update
            metric['value'] = value
            metric['metric_options'] = {}
            metric['metric_options']['plugin'] = plugin
            metric['metric_options']['plugin_instance'] = plugin_instance
            metric['metric_options']['type'] = type
            metric['metric_options']['type_instance'] = type_instance
            metric['metric_options']['ds'] = ds
            #puts metric.inspect
            r << metric
          end
          socket.close
        end
        return r
      end

      def get_all_metrics(hostname)
        rel_host_path = host = hostname
        host_path = File.join(@path,rel_host_path)
        #puts "+++++++++ scanning #{host_path}"
        if File.directory?(host_path) and not host =~ /^\./
          host_metrics = Array.new
          # Each dir is a plugin
          Dir.foreach(host_path) do |plugin|
            rel_plugin_path = File.join(rel_host_path, plugin)
            plugin_path = File.join(@path,rel_plugin_path)
            if File.directory?(plugin_path) and not plugin =~ /^\./
              plugin_files = Array.new
              Dir.foreach(plugin_path) do |file|
                rel_file_path = File.join(rel_plugin_path, file)
                file_path = File.join(@path, rel_file_path)
                if File.file?(file_path) and file =~ /\.rrd$/
                  # This is an rrd data file
                  plugin_files << {
                    :full_path => file_path,
                    :relative_path => rel_file_path
                  }
                end
              end
                
              if plugin_files.length > 0
                handler = Plugins.from_shortname("default")
                h = handler.new(plugin_files, plugin)
                host_metrics = host_metrics + h.metrics
              end
            end
          end
        end
        #puts "+++++++++ #{host_metrics.inspect}"
        host_metrics
      end
      
      def get_data(start_date, end_date, metric, metric_value_kind, hostname, resolution = nil)
        flush_rrdcache(metric)
        metric_options = metric['metric_options']
        metric_group = metric_options['metric_group']
        metric_rrd = metric_options['metric_rrd'] 
        metric_rrd = metric_rrd << ".rrd" unless metric_rrd.include? ".rrd"
        ds = metric_options['ds']

        rrd = RRD::Base.new(File.join(@path, hostname, metric_group, metric_rrd))

#        puts "------------------start------------------"
        options = {:start => start_date, :end => end_date}
        options[:resolution] = resolution if resolution
        results = rrd.fetch(metric_value_kind, options)
        puts "DEBUG get_data for #{metric['metric']}, working with RRD: #{@path}/#{hostname}/#{metric_group}/#{metric_rrd}, value kind: #{metric_value_kind}, options: #{options.inspect}"

        r = Array.new
        if results
          index = results.first.index(ds)
          # Delete first line of results as it contains rra names
          results.delete_at(0)
        
          results.each do |line|
            r << [line[0], line[index]] if index and line[index]# and line[index].class == Float and !line[index].nan?
          end
        else
          puts "ERROR: "<<" rrd fetch failed: "<< rrd.error
        end
#        puts "------------------done-------------------"
        rrd = nil
        r
      end

      def get_last_value(start_date, end_date, metric, metric_value_kind, hostname)
        flush_rrdcache(metric)
        metric_options = metric['metric_options']
        metric_group = metric_options['metric_group']
        metric_rrd = metric_options['metric_rrd'] << ".rrd"
        ds = metric_options['ds']

        rrd = RRD::Base.new(File.join(@path, hostname, metric_group, metric_rrd))

        #        puts "------------------start------------------"
        results  = rrd.info
        rrd = nil
        if results
          timestamp = results['last_update']
          value = results['ds['+ds+'].last_ds']
          return {metric['metric'] => [timestamp, value]}
        else
          puts "ERROR: "<<" rrd fetch failed: "<< rrd.error
          return nil
        end
        #        puts "------------------done-------------------"
      end
      
      # Connects to unix socket and send FLUSH to write data from collectd cache to rrd files
      # This is meant to be used by graphing or displaying front-ends which want to have the latest values for a specific graph.
      # see http://collectd.org/wiki/index.php/Inside_the_RRDtool_plugin
      def flush_rrdcache(metric)
        #puts "DEBUG #{metric.inspect}"
        identifier = "#{metric['metric_options']['path']}/#{metric['metric_options']['metric_rrd']}"
        socket_path = "/var/run/collectd-socket"
        socket = UNIXSocket.new(socket_path)
        socket.puts("FLUSH plugin=rrdtool identifier=\"#{identifier}\"")
        result = socket.gets      
        socket.close      
        puts "DEBUG flush_rrdcache for #{identifier} #{result}"
      end

      DataProvider.register(self)
    end
  end
end
