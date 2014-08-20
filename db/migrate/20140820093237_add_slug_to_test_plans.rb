class AddSlugToTestPlans < ActiveRecord::Migration
  def change
    add_column :test_plans, :slug, :string
    add_index :test_plans, :slug, unique: true
  end
end
