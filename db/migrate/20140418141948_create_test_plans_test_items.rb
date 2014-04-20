class CreateTestPlansTestItems < ActiveRecord::Migration
  def change
    create_table :test_plans_test_items do |t|
          t.belongs_to :test_plan
          t.belongs_to :test_item
    end
  end
end
