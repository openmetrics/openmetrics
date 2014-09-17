# == Schema Information
#
# Table name: services
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  type         :string(255)
#  description  :text
#  daemon_name  :string(255)
#  init_name    :string(255)
#  systemd_name :string(255)
#  fqdn         :string(255)
#

class Service < ActiveRecord::Base
  include Exportable

  has_many :running_services
  has_many :systems, through: :running_services

  # returns Array of RunningService's
  def systems_running_service
    running_services = RunningService.where(service_id: self.id)
    ret = []
    if running_services != nil
      for rs in running_services
        system = nil
        system = System.find_by_id(rs.system_id, :include =>  :running_services ) unless rs.system_id == nil
        if system != nil
          ret.push(rs)
        end
      end
    end
    return ret
  end

end
