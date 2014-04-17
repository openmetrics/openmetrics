class AddSystemIdToRunningService < ActiveRecord::Migration
  def change
    add_column :running_services, :system_id, :integer
  end
end
