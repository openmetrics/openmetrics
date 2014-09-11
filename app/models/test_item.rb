class TestItem < ActiveRecord::Base
  include Qualifiable

  attr_readonly(:type)
  #has_and_belongs_to_many :test_plans, :join_table => :test_plans_test_items
  #has_many :test_plans, through: :test_plan_items
  belongs_to :test_item_type
  before_create :set_type

  def set_type()
      test_item_type = TestItemType.find_by_model_name(self.class)
  end
end
