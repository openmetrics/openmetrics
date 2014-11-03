class QualityCriterion < ActiveRecord::Base
  belongs_to :qualifiable, polymorphic: true
  belongs_to :test_plan

  def referred_object
    self.qualifiable_type.constantize.find_by id: self.qualifiable_id
  end
end