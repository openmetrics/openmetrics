class RemoveScanresultFromIpLookup < ActiveRecord::Migration
  def change
    remove_column :ip_lookups, :scanresult, :text
  end
end
