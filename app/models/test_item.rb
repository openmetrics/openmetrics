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

  # returns Array of TestPlan's
  def test_plans
    tpi = TestPlanItem.where(test_item_id: self.id)
    ret = []

    for i in tpi
      tp = i.test_plan
      unless tp.nil? or ret.include?(tp)
        ret.push(tp)
      end
    end
    return ret
  end


  def provided_input
    if self.format == 'selenese'
      WebtestAutomagick::selenese_extract_input(self.markup)
    elsif self.format == 'ruby'
      WebtestAutomagick::ruby_extract_input(self.markup)
    else
      []
    end
  end

  def provides_input?
    if self.format == 'selenese'
      self.markup.include?('<td>store</td>')
    elsif self.format == 'ruby'
      self.markup.scan(/ENV\[['"]([a-zA-Z0-9]+)['"]\]\s?=/).any?
    else
      false
    end
  end
  alias_method :input_provided?, :provides_input?

  def provides_random_input?
    self.provided_input.collect{|i| i.second.nil?}.any?
  end
  alias_method :random_input?, :provides_random_input?

  def requires_input?
    # selenese uses ${varname} notation to reference variables
    if self.format == 'selenese'
      return true if self.markup.scan(/\$\{[a-zA-Z0-9]*\}/).any?
    end
    false
  end
  alias_method :input_required?, :requires_input?

  def required_input
    if self.format == 'selenese'
      WebtestAutomagick::selenese_input_references(self.markup)
    else
      nil
    end
  end

end
