class Quality < ActiveRecord::Base
  belongs_to :quality_criterion
  belongs_to :test_execution
end