# == Schema Information
#
# Table name: running_collectd_plugins
#
#  id                 :integer          not null, primary key
#  collectd_plugin_id :integer
#  running_service_id :integer
#  system_id          :integer
#

class RunningCollectdPlugin < ActiveRecord::Base
  #include SshAutomagick # to enable collectd plugin

  belongs_to :collectd_plugin
  belongs_to :running_service
  belongs_to :system

  after_commit :enable_plugin, on: :create

  def enable_plugin
    begin
      SshAutomagick::enable_collectd_plugin(self.collectd_plugin, self.system)
    rescue Exception => e
      logger.error "Failed to enable running_collectd_plugin #{self.id} due to exception #{e.message}"
    end
  end
end
