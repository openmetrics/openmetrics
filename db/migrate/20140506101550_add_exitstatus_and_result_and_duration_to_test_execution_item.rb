class AddExitstatusAndResultAndDurationToTestExecutionItem < ActiveRecord::Migration
  def change
    add_column :test_execution_items, :exitstatus, :integer
    add_column :test_execution_items, :result, :text
    add_column :test_execution_items, :duration, :integer
  end
end
