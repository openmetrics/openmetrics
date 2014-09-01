class AddSshUserToSystem < ActiveRecord::Migration
  def change
    add_column :systems, :sshuser, :string
  end
end
