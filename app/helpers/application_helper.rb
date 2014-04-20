module ApplicationHelper
  include HtmlFormbakery
  include HtmlTablebakery

  def javascript(*files)
    content_for(:additional_js) do
      javascript_include_tag(*files)
    end
  end

  def coderay(text, format)
    case format
      when 'selenese'
        format = 'html'
      when 'bash'
        format = 'sh'
    end
   raw CodeRay.scan("#{text}", format).div(:line_numbers => :table)
  end

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
