class AddTimestampsToTestExecutionItem < ActiveRecord::Migration
  def change
    add_column :test_execution_items, :created_at, :datetime
    add_column :test_execution_items, :updated_at, :datetime
  end
end
