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
  has_and_belongs_to_many :systems

#  def to_s_system_with_identifier
#    self.system.fqdn + "::" + self.group + "/" + self.plugin + "/" + self.ds
#  end

  def to_s_identifier
    self.group + "/" + self.plugin + "/" + self.ds
  end
end
