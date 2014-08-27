class System < ActiveRecord::Base
  include Trackable
  include Sluggable
  include Exportable

  has_many :running_services
  has_many :services, :through => :running_services
  # has_many :active_services, ->{ where(active: true).order(:name) },
  #           through: :running_service,
  #           class_name: 'Service',
  #           source: :system

  # create a running service:
  # s = System.first; ss = Service.first
  # s.running_services << RunningService.new(service:ss, system: s, type: ss.type, description: 'hello')

  validates :name, :presence => true, length: {minimum: 3},
                   :uniqueness => true, :format => { :with => /[A-Za-z0-9::space::]+/ }
end
