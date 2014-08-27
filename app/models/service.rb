class Service < ActiveRecord::Base
  include Exportable

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
