class CreateSystemLookupResult < ActiveRecord::Migration
  def change
    create_table :system_lookup_results do |t|
      t.integer :system_lookup_id
      t.text :result
    end
  end
end
