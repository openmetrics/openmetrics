module ApplicationHelper
  include HtmlFormbakery
  include HtmlTablebakery

  def javascript(*files)
    content_for(:additional_js) do
      javascript_include_tag(*files)
    end
  end

  def coderay(text, format, container="span")
    case format
      when 'selenese'
        format = 'html'
      when 'bash'
        format = 'sh'
    end
   raw CodeRay.scan("#{text}", format).div()
  end

end
