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

  # helper for helper :)
  def badge_label(object, *options)
    opt = options.extract_options! # returns Hash
    label_class = opt[:label_class] || 'default'
    object_class = object.class.name
    default_text = if object.respond_to? :name
             object.name
           else
             "unnamed Object"
           end
    text = opt[:text] || default_text
    raw(badge("#{object_class.to_acronym}-#{object.id}", label_class)) + " #{text}"
  end

  # sets data-no-turbolink attribute to html body tag, to disable turbolinks on a specific page
  def disable_turbolinks!
    content_for :body_tags, 'data-no-turbolink'
  end

  # converts given hash of changes to a nicely formatted string (contains html)
  def changes_to_string(changes)
    changes_arr = []
    changes.each do |field, value|
      tmp_str = "<strong>#{field.humanize}:</strong> "
      # value[0] is origin value, value[1] is value changed to
      tmp_str += "#{value[0]} <i class=\"fa fa-long-arrow-right\"></i> " unless value[0].nil? or value[1].nil?

      # add minus sign if value is null now
      if value[1].nil?
        tmp_str += "<i class=\"fa fa-minus\"></i> #{value[0]}"
      end

      # add a plus sign if value wasn't set before
      if value[0].nil? or value[0].empty?
        tmp_str += "#{value[0]} <i class=\"fa fa-plus\"></i> "
      end
      tmp_str += "#{value[1]}" unless value[1].nil?
      changes_arr.push(tmp_str)
    end
    raw changes_arr.to_sentence
  end

end
