class CreateTestItems < ActiveRecord::Migration
  def change
    create_table :test_items do |t|
      t.string :type

      t.timestamps
    end
  end
end
