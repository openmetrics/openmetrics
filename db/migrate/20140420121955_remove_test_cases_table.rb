class RemoveTestCasesTable < ActiveRecord::Migration
  def change
    drop_table :test_cases
  end
end
