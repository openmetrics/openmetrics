class CreateCollectdPlugins < ActiveRecord::Migration
  def change
    create_table :collectd_plugins do |t|
      t.string :name
      t.text :configuration
    end
  end
end
