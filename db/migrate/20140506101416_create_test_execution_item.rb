class CreateTestExecutionItem < ActiveRecord::Migration
  def change
    create_table :test_execution_items do |t|
      t.string :format
      t.text :markup
      t.integer :test_execution_id
    end
  end
end
