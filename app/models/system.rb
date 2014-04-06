class System < ActiveRecord::Base
  has_many :services, :through => :running_services
  validates :name, :presence => true, length: {minimum: 3},
                   :uniqueness => true, :format => { :with => /[A-Za-z0-9::space::]+/ }
end
