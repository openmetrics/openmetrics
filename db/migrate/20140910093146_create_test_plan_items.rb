class CreateTestPlanItems < ActiveRecord::Migration
  def change
    create_table :test_plan_items do |t|
      t.integer :test_plan_id
      t.integer :test_item_id
      t.integer :position
    end
  end
end
