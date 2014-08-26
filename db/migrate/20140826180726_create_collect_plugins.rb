class CreateCollectPlugins < ActiveRecord::Migration
  def change
    create_table :collect_plugins do |t|
      t.string :name
      t.text :configuration
    end
  end
end
