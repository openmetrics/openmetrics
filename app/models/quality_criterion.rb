class QualityCriterion < ActiveRecord::Base
  belongs_to :test_plan
  def test_plan
    TestPlan.find(self.entity_id)
  end
end