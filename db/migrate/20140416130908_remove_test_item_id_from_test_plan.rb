class RemoveTestItemIdFromTestPlan < ActiveRecord::Migration
  def change
    remove_column :test_plans, :test_item_id, :integer
  end
end
