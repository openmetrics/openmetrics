class AddPositionToTestExecutionItem < ActiveRecord::Migration
  def change
    add_column :test_execution_items, :position, :integer
  end
end
