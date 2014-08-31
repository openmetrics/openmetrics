class System < ActiveRecord::Base
  include Trackable
  include Sluggable
  include Exportable

  has_many :running_services, dependent: :destroy
  has_many :services, through: :running_services
  accepts_nested_attributes_for :running_services, allow_destroy: true #, reject_if: proc { |attributes| attributes['name'].blank? }
  has_and_belongs_to_many :metrics
  #has_many :running_collectd_plugins
  has_many :running_collectd_plugins, dependent: :destroy
  accepts_nested_attributes_for :running_collectd_plugins#, allow_destroy: true #, reject_if: proc { |attributes| attributes['name'].blank? }

  validates :name, :presence => true, length: {minimum: 3},
                   :uniqueness => true, :format => { :with => /[A-Za-z0-9::space::]+/ }
end
