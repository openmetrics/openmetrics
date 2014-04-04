class Service < ActiveRecord::Base
  has_many :systems, :through => :running_services
end
