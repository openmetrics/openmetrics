class AddStartedAtAndFinishedAtToIpLookup < ActiveRecord::Migration
  def change
    add_column :ip_lookups, :started_at, :datetime
    add_column :ip_lookups, :finished_at, :datetime
  end
end
