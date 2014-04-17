class AddServiceIdToRunningService < ActiveRecord::Migration
  def change
    add_column :running_services, :service_id, :integer
  end
end
