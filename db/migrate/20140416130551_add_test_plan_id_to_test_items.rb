class AddTestPlanIdToTestItems < ActiveRecord::Migration
  def change
    add_column :test_items, :test_plan_id, :integer
  end
end
