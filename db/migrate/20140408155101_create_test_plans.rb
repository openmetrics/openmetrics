class CreateTestPlans < ActiveRecord::Migration
  def change
    create_table :test_plans do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.integer :test_item_id

      t.timestamps
    end
  end
end
