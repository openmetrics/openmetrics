module ApplicationHelper
  include HtmlFormbakery
  include HtmlTablebakery

  # include js from within view
  def javascript(*files)
    content_for(:additional_js) do
      javascript_include_tag(*files)
    end
  end

  # renders text with synthax highligh
  def coderay(text, format, container="span")
    case format
      when 'selenese'
        format = 'html'
      when 'bash'
        format = 'sh'
    end

    raw container == "span" ? CodeRay.scan("#{text}", format).span() : CodeRay.scan("#{text}", format).div()
  end

  # helper to insert bootstrap badge
  def badge(text, label_class='default')
    raw "<span class=\"label label-#{label_class}\">" + (text.is_a?(String) ? text : '') + '</span>'
  end

end
