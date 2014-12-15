class AddTimestampsToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :created_at, :datetime
    add_column :metrics, :updated_at, :datetime
  end
end
