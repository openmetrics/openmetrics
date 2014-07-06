class System < ActiveRecord::Base
  include Trackable

  has_many :running_services
  has_many :services, :through => :running_services
  # has_many :active_services, ->{ where(active: true).order(:name) },
  #           through: :running_service,
  #           class_name: 'Service',
  #           source: :system

  validates :name, :presence => true, length: {minimum: 3},
                   :uniqueness => true, :format => { :with => /[A-Za-z0-9::space::]+/ }
end
