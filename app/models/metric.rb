# == Schema Information
#
# Table name: metrics
#
#  id       :integer          not null, primary key
#  plugin   :string(255)
#  ds       :string(255)
#  name     :string(255)
#  rrd_file :string(255)
#

class Metric < ActiveRecord::Base
  include Trackable
  has_and_belongs_to_many :systems, limit: 1 # something like has_and_belongs_to_one

  # disable STI
  # type column shouldnt be needed at all, but it could be used to have easy access to type (as String)
  # otherwise ActiveRecord::SubclassNotFound: Invalid single-table inheritance type: HttpService is not a subclass of RunningService
  self.inheritance_column = :_type_disabled

  # something like has_and_belongs_to_one
  def system
   self.systems.first
  end

  def get_data
    begin
      self.system.send('get_metric_values', self.name)
    rescue
      []
    end
  end

#  def to_s_system_with_identifier
#    self.system.fqdn + "::" + self.group + "/" + self.plugin + "/" + self.ds
#  end

  # def to_s_identifier
  #   self.group + "/" + self.plugin + "/" + self.ds
  # end
end
