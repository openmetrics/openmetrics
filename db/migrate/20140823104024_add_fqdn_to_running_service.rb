class AddFqdnToRunningService < ActiveRecord::Migration
  def change
    add_column :running_services, :fqdn, :string
  end
end
