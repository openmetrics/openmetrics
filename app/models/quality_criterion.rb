class QualityCriterion < ActiveRecord::Base
  belongs_to :qualifiable, polymorphic: true
end