class RunningCollectdPlugin < ActiveRecord::Base
  belongs_to :collectd_plugin
  belongs_to :running_service
  has_one :system, through: :running_service

  after_commit :enable_plugin, on: :create

  def enable_plugin
    begin
      enable_collectd_plugin(self.collectd_plugin, self.system)
    rescue Exception => e
      logger.error "Failed to enable running_collectd_plugin #{self.id} due to exception #{e.message}"
    end
  end
end