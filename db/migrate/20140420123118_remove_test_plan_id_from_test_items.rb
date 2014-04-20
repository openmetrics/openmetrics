class RemoveTestPlanIdFromTestItems < ActiveRecord::Migration
  def change
    remove_column :test_items, :test_plan_id, :integer
  end
end
