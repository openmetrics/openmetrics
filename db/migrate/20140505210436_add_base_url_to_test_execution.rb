class AddBaseUrlToTestExecution < ActiveRecord::Migration
  def change
    add_column :test_executions, :base_url, :string
  end
end
