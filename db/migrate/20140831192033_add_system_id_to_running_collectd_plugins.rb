class AddSystemIdToRunningCollectdPlugins < ActiveRecord::Migration
  def change
    add_column :running_collectd_plugins, :system_id, :integer
  end
end
