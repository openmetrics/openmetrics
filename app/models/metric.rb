class Metric < ActiveRecord::Base
  has_and_belongs_to_many :systems

#  def to_s_system_with_identifier
#    self.system.fqdn + "::" + self.group + "/" + self.plugin + "/" + self.ds
#  end

  def to_s_identifier
    self.group + "/" + self.plugin + "/" + self.ds
  end
end
