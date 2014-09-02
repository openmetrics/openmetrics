class RemoveGroupFromMetrics < ActiveRecord::Migration
  def change
    remove_column :metrics, :group, :string
  end
end
