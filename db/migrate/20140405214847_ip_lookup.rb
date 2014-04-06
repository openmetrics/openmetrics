class IpLookup < ActiveRecord::Migration
  def change
    create_table :ip_lookups do |t|
      t.string :target
      t.text :scanresult
      t.string :job_key
      t.integer :user_id

      t.timestamps
    end
  end
end
