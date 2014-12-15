class AddPluginInstanceAndTypeAndTypeInstanceToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :plugin_instance, :string
    add_column :metrics, :type, :string
    add_column :metrics, :type_instance, :string
  end
end
