class ModifyTestExecutionResult < ActiveRecord::Migration
  def change
      add_column :test_execution_items, :status, :integer
      add_column :test_execution_items, :error, :text
      add_column :test_execution_items, :started_at, :datetime
      add_column :test_execution_items, :finished_at, :datetime
      remove_column :test_execution_items, :duration, :integer
      remove_column :test_execution_items, :result, :text

      change_column :test_execution_results, :duration, :decimal
      remove_column :test_execution_results, :output, :text

  end
end
