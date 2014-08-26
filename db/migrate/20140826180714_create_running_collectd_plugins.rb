class CreateRunningCollectdPlugins < ActiveRecord::Migration
  def change
    create_table :running_collectd_plugins do |t|
      t.integer :collectd_plugin_id
      t.integer :running_service_id
    end
  end
end
