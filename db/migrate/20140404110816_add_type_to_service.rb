class AddTypeToService < ActiveRecord::Migration
  def up
   add_column :running_services, :type, :string
  end
end
