class System < ActiveRecord::Base
  has_many :services, :through => :running_services
end
