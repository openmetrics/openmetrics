class Service < ActiveRecord::Base
  has_many :systems, :through => :running_services
  has_many :systems
end
