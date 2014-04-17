module ApplicationHelper
  include HtmlFormbakery
  include HtmlTablebakery

  def flash_class(severity)
    case severity
        when :notice then "alert alert-info"
        when :success then "alert alert-success"
        when :warning then "alert alert-warning"
        when :warn then "alert alert-warning"
        when :fail then "alert alert-warning"
        when :failure then "alert alert-warning"
        when :error then "alert alert-danger"
        when :alert then "alert alert-danger"
        when :danger then "alert alert-danger"
        else "alert alert-info"
    end
  end

end
