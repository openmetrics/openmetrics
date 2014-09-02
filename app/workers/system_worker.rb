
class SystemWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(system_id)
    system = System.find system_id
    create_or_update_metrics(system)
  end

  # connect to collectd socket and create/update metrics from given results
  def create_or_update_metrics(system)
    system_metrics = system.list_metrics
    system_metrics.each do |metric|
      m = Metric.find_or_create_by(
            name: metric['metric'],
            rrd_file: metric['metric_options']['rrd_file'],
            ds: metric['metric_options']['ds'],
            plugin: metric['metric_options']['plugin']
      )
      if m.new_record?
        logger.info("Created new metric for System##{system.id}: #{m.inspect}")
      end
      system.metrics << m
    end
  end


end

