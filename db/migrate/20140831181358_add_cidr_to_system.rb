class AddCidrToSystem < ActiveRecord::Migration
  def change
    #add_column :systems, :cidr, :cidr
    add_column :systems, :cidr, :string
  end
end
