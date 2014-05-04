class CreateTestExecutionResults < ActiveRecord::Migration
  def change
    create_table :test_execution_results do |t|
      t.integer :test_execution_id
      t.text :result
      t.integer :duration
      t.text :output
      t.integer :exitstatus

      t.timestamps
    end
  end
end
