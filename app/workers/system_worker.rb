
class SystemWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform
    System.all.each do |system|
      create_or_update_metrics(system)
    end
  end

  # connect to collectd socket and create/update metrics from given results
  def create_or_update_metrics(system)
    system_metrics = system.list_metrics
    system_metrics.each do |metric|
      m = Metric.find_or_initialize_by(
            host: metric['host'],
            name: metric['identifier'],
            rrd_file: metric['identifier']+'.rrd',
            plugin: metric['metric_options']['plugin'],
            plugin_instance: metric['metric_options']['plugin_instance'],
            type: metric['metric_options']['type'],
            type_instance: metric['metric_options']['type_instance'],
            ds: metric['metric_options']['ds']
      )

      if m.new_record?
        logger.info("Created new metric for System##{system.id}: #{m.inspect}")
        m.save!
      else
        # update metric
      end

    end
  end

end

