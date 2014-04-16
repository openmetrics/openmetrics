class CreateTestItemTypes < ActiveRecord::Migration

  def self.up
    create_table :test_item_types do |t|
      t.string :model_name, :null => false
      t.string :name, :null => false
      t.text :description

      t.timestamps
    end

    add_index :test_item_types, :model_name, :unique => true


    #all project types that are used.
    models_names = {"TestSuite" => "A suite of TestCases",
                    "TestCase" => "A TestCase"}

    #key for model_name and value for name
    models_names.each do |key, value|
      p = TestItemType.new();
      p.model_name = key
      p.name = value
      p.save
    end

  end

  def self.down
    drop_table :test_item_types
  end
end
