# == Schema Information
#
# Table name: systems
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  fqdn                     :string(255)
#  operating_system         :string(255)
#  operating_system_flavour :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  slug                     :string(255)
#  description              :text
#  cidr                     :string(255)
#  sshuser                  :string(255)
#

class System < ActiveRecord::Base
  include Exportable
  include Sluggable
  include Taggable
  include Trackable
  include Truncatable

  has_secretary on: %w( cidr description fqdn name operating_system operating_system_flavor sshuser )
  has_many :running_services, -> { includes(:service).order("services.name")}, dependent: :destroy
  tracks_association :running_services # by rails-secretary gem
  has_many :services, through: :running_services
  accepts_nested_attributes_for :running_services, allow_destroy: true #, reject_if: proc { |attributes| attributes['name'].blank? }
  has_and_belongs_to_many :metrics
  has_many :running_collectd_plugins
  accepts_nested_attributes_for :running_collectd_plugins, allow_destroy: true #, reject_if: proc { |attributes| attributes['name'].blank? }
  has_many :system_lookups, ->{order("id DESC")}

  strip_attributes
  validates :name, :presence => true, length: {minimum: 3},
                   :uniqueness => true, :format => { :with => /[A-Za-z0-9::space::]+/ }



  #
  # TODO if socket holds recent data, e.g. because host (or collectd on that box died there should be a fallback to get metrics from existing rrd files
  def list_metrics
    data_provider.get_all_metrics_from_socket(self.fqdn)
  end

  def get_metric_values(identifier)
    data_provider.get_data_from_socket(identifier)
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
