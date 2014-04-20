class ChangeTestCase < ActiveRecord::Migration
  def change
    add_column :test_items, :format, :string
    add_column :test_items, :markup, :text
  end
end
