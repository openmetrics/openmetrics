class AddStatusToIpLookup < ActiveRecord::Migration
  def change
    add_column :ip_lookups, :status, :integer
  end
end
