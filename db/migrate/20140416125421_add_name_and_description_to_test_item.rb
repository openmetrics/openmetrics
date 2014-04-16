class AddNameAndDescriptionToTestItem < ActiveRecord::Migration
  def change
    add_column :test_items, :name, :string
    add_column :test_items, :description, :text
  end
end
