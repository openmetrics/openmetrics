class AddNamesToServices < ActiveRecord::Migration
  def change
    add_column :services, :daemon_name, :string
    add_column :services, :init_name, :string
    add_column :services, :systemd_name, :string
  end
end
