class TestPlanItem < ActiveRecord::Base
  belongs_to :test_plan
  belongs_to :test_item

  # disable STI
  # type column shouldnt be needed at all, but it could be used to have easy access to type (as String)
  # otherwise ActiveRecord::SubclassNotFound: Invalid single-table inheritance type: HttpService is not a subclass of RunningService
  self.inheritance_column = :_type_disabled
end
