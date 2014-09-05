class RenameSystemsOperatingSystemFlavourToOperatingSystemFlavor < ActiveRecord::Migration
  def change
    rename_column :systems, :operating_system_flavour, :operating_system_flavor
  end
end
