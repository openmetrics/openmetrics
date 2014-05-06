class AddOutputToTestExecutionItem < ActiveRecord::Migration
  def change
    add_column :test_execution_items, :output, :text
  end
end
