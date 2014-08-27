class AddDescriptionToCollectdPlugin < ActiveRecord::Migration
  def change
    add_column :collectd_plugins, :description, :text
  end
end
