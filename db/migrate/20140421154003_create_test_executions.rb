class CreateTestExecutions < ActiveRecord::Migration
  def change
    create_table :test_executions do |t|
      t.integer :test_plan_id
      t.integer :user_id
      t.integer :status

      t.timestamps
    end
  end
end
