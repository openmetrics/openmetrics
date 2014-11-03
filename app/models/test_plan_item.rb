class TestPlanItem < ActiveRecord::Base
  belongs_to :test_plan
  belongs_to :test_item
  acts_as_list scope: :test_plan

  def quality_criteria
    QualityCriterion.where(qualifiable_id: self.test_item.id, qualifiable_type: 'TestItem', test_plan_id: self.test_plan.id, position: self.position)
  end

  # disable STI
  # type column shouldnt be needed at all, but it could be used to have easy access to type (as String)
  # otherwise ActiveRecord::SubclassNotFound: Invalid single-table inheritance type: HttpService is not a subclass of RunningService
  self.inheritance_column = :_type_disabled
end
