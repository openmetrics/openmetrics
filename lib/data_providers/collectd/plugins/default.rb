require File.expand_path('../base', __FILE__)

module DataProvider
  module Collectd
    module Plugins
      class Default < Base
        def initialize(files, plugin)
          @files = files
          @plugin = plugin
        end
        
        def metrics
          r = Array.new
          @files.each do |file|
            data_sources = Hash.new
            rrd = RRD::Base.new(file[:full_path])
            results = rrd.info
            if results
              results.each do |term, val|
                if term.to_s =~ /^ds\[.*\]\.type/
                  rindex = term.to_s.rindex("]") - 3
                  ds = term[3,rindex]
                  if !data_sources[ds]
                    data_sources[ds] = val
                  end
                end
              end
            else
              puts "ERROR: "<<" rrdtool info failed for "<< File.basename(file[:full_path], '.rrd')
            end

            
            data_sources.each do |ds,val|
              r << metric = {}
              metric['metric'] = @plugin + "_" + File.basename(file[:full_path], '.rrd') + "_" + ds
              metric['metric_options'] = {}
              metric['metric_options']['path'] = file[:relative_path]
              metric['metric_options']['ds'] = ds
              metric['metric_options']['metric_group'] = @plugin
              metric['metric_options']['metric_rrd'] = File.basename(file[:full_path], '.rrd').to_s
            end
          end
          r
        end
        
        Plugins.register(self)
      end
    end
  end
end
