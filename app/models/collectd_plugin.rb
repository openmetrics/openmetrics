class CollectdPlugin < ActiveRecord::Base
  has_many :running_collectd_plugins
end