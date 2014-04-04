module ApplicationHelper

  def flash_class(severity)
    case severity
        when :notice then "alert alert-info"
        when :success then "alert alert-success"
        when :error then "alert alert-danger"
        when :alert then "alert alert-danger"
        when :danger then "alert alert-danger"
    end
  end
end
