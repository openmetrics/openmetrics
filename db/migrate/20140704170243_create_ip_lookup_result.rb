class CreateIpLookupResult < ActiveRecord::Migration
  def change
    create_table :ip_lookup_results do |t|
      t.integer :ip_lookup_id
      t.text :result
      t.timestamps
    end
  end
end
