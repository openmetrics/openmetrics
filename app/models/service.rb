class Service < ActiveRecord::Base
  has_many :systems, :through => :running_service
  has_many :systems
end
