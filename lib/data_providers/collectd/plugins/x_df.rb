require File.expand_path('../base', __FILE__)

module DataProvider
  module Collectd
    module Plugins
      class Df < Base
        def initialize(files)
          @files = files
        end

        def metrics
          r = Array.new
          @files.each do |file|
            {'used' => 'used', 'free' => 'free'}.each do |term,val|
              r << metric = MetricResult.new
              metric.name = "df " + File.basename(file[:full_path], '.rrd').split('-')[1] + " - #{val}"
              puts  "\t\t" + metric.name
              metric.tags << 'System/df'
              metric.options[:path] = file[:relative_path]
              metric.options[:ds] = term
              metric.options[:minimum] = 0
            end
          end
          r
        end

        Plugins.register(self)
      end
    end
  end
end
