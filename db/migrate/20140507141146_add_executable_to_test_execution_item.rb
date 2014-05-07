class AddExecutableToTestExecutionItem < ActiveRecord::Migration
  def change
    add_column :test_execution_items, :executable, :text
  end
end
