class CreateSystems < ActiveRecord::Migration
  def change
    create_table :systems do |t|
      t.string :name
      t.string :fqdn
      t.string :operating_system
      t.string :operating_system_flavour

      t.timestamps
    end
  end
end
