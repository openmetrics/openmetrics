class Service < ActiveRecord::Base
  include Exportable

  has_many :systems, :through => :running_service
  has_many :systems

  def systems_running_service
    running_services = RunningService.where(service_id: self.id)
    systems = Hash.[]
    if running_services != nil
      for rs in running_services
        system = nil
        system = System.find_by_id(rs.system_id, :include =>  :running_services ) unless rs.system_id == nil
        if system != nil
          systems[rs.id] = system
        end
      end
    end
    return systems
  end

end
