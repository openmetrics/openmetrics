class AddDescriptionToSystems < ActiveRecord::Migration
  def change
    add_column :systems, :description, :text
  end
end
