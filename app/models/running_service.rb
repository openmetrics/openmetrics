class RunningService < ActiveRecord::Base
  belongs_to :system
  belongs_to :service
end
