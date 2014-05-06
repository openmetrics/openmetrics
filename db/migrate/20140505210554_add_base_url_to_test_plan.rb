class AddBaseUrlToTestPlan < ActiveRecord::Migration
  def change
    add_column :test_plans, :base_url, :string
  end
end
