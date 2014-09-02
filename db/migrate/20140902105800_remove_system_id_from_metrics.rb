class RemoveSystemIdFromMetrics < ActiveRecord::Migration
  def self.up
    remove_column :metrics, :system_id
  end

  def self.down
    add_column :metrics, :system_id
  end
end
