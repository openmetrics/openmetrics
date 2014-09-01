module ApplicationHelper
  include HtmlFormbakery
  include HtmlTablebakery
  include SshAutomagick

  # include js from within view
  def javascript(*files)
    content_for(:additional_js) do
      javascript_include_tag(*files)
    end
  end

  # renders text with synthax highligh
  def coderay(text, format='plain', container='span')
    case format
      when 'bash'
        format = 'sh'
      when 'selenese'
        format = 'html'
      when 'ruby'
        format = 'ruby'
    end

    raw container == "span" ? CodeRay.scan("#{text}", format.to_sym).span() : CodeRay.scan("#{text}", format.to_sym).div()
  end

  # helper to insert bootstrap badge
  def badge(text, label_class='default')
    raw "<span class=\"label label-#{label_class}\">" + (text.is_a?(String) ? text : '') + '</span>'
  end

  # sets data-no-turbolink attribute to html body tag, to disable turbolinks on a specific page
  def disable_turbolinks!
    content_for :body_tags, 'data-no-turbolink'
  end

end
