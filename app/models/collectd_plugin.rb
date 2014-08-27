class CollectdPlugin < ActiveRecord::Base
  has_many :running_collectd_plugins

  # returns Array of RunningService's
  def running_services
    rcps = RunningCollectdPlugin.where(collectd_plugin_id: self.id)
    ret = []
    if rcps != nil
      for rcp in rcps
        rs = nil
        rs = RunningService.find_by_id(rcp.running_service_id) unless rcp.running_service_id == nil
        if rs != nil
          ret.push(rs)
        end
      end
    end
    return ret
  end
end