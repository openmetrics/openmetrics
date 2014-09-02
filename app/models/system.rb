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

  #
  # TODO if socket holds recent data, e.g. because host (or collectd on that box died there should be a fallback to get metrics from existing rrd files
  def list_metrics
    return data_provider.get_all_metrics_from_socket(self.fqdn)
  end

  def data_provider
    unless @data_provider
      require File.expand_path("../../../lib/data_providers/collectd/collectd", __FILE__)
      klass = DataProvider.from_shortname("collectd")
      @data_provider = klass.new()
    end
    @data_provider
  end
end
