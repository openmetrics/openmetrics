class AddTestItemIdToTestExecutionItem < ActiveRecord::Migration
  def change
    add_column :test_execution_items, :test_item_id, :integer
  end
end
