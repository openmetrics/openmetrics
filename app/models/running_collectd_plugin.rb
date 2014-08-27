class RunningCollectdPlugin < ActiveRecord::Base
  belongs_to :collectd_plugin
  belongs_to :running_service
end
