class AddFqdnToService < ActiveRecord::Migration
  def change
    add_column :services, :fqdn, :string
  end
end
