class TestItem < ActiveRecord::Base
  attr_readonly(:type)
  #belongs_to :test_plan
  belongs_to :test_item_type
  before_create :set_type

  def set_type()
      test_item_type = TestItemType.find_by_model_name(self.class)
  end
end