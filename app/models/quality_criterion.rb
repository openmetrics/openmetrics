class QualityCriterion < ActiveRecord::Base
  belongs_to :qualifiable, polymorphic: true
  belongs_to :test_plan
end