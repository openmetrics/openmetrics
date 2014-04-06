module ApplicationHelper
  include HTMLFormbakery
  include HTMLTablebakery

  def flash_class(severity)
    case severity
        when :notice then "alert alert-info"
        when :success then "alert alert-success"
        when :error then "alert alert-warning"
        when :alert then "alert alert-warning"
        when :danger then "alert alert-warning"
    end
  end

end
