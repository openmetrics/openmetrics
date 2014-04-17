class CreateWebtests < ActiveRecord::Migration
  def change
    create_table :webtests do |t|
      t.text :description
      t.string :base_url
      t.integer :user_id
      t.timestamps
    end
  end
end
