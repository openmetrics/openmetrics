module ApplicationHelper
  include HtmlFormbakery
  include HtmlTablebakery

  # include js from within view
  def javascript(*files)
    content_for(:additional_js) do
      javascript_include_tag(*files)
    end
  end

  # renders text with synthax highlight
  # see http://www.rubydoc.info/github/rubychan/coderay/CodeRay/Encoders/HTML for coderay options
  def coderay(text, format='plain', container='span', line_numbers=false)
    opts = {}

    case format
      when 'bash'
        format = 'sh'
      when 'selenese'
        format = 'html'
      when 'ruby'
        format = 'ruby'
    end

    if container == "span"
      opts[:wrap] = :span
    else
      opts[:wrap] = :div
    end

    # possible opts are :inline, :table or :nil (default)
    if line_numbers
      opts[:line_numbers] = :inline
    end


    raw CodeRay.scan("#{text}", format.to_sym).html(opts)
  end

  # helper to insert bootstrap badge
  def badge(text, label_class='default')
    raw "<span class=\"label label-#{label_class}\">" + (text.is_a?(String) ? text : '') + '</span>'
  end

  # helper for helper :)
  def badge_label(object, *options)
    opt = options.extract_options! # returns Hash
    label_class = opt[:label_class] || 'default'
    truncate = opt[:truncate] || false
    # use base_class here to show parent classname of sti model, e.g. 'Service' instead of 'HttpService'
    object_class = opt[:use_base_class] ? object.class.base_class.name : object.class.name
    default_text = object.respond_to?(:name) ? object.name : "unnamed Object"
    text = opt[:text] || default_text

    # truncate text after certain characters?
    if truncate.is_a? Integer
      text = truncate(text, length: truncate, separator: ' ')
    end

    # sub_label? extend text with it
    if opt[:sub_label]
      sub_text = opt[:sub_label][:text] || ''
      sub_label_class = opt[:sub_label][:label_class] || 'default'
      text = badge(sub_text, sub_label_class) + " #{text}"
    end

    if current_user.show_labels == 'none'
      raw(text)
    elsif current_user.show_labels == 'short'
      raw(badge("#{object_class.to_acronym}-#{object.id}", label_class)) + raw(" #{text}")
    else
      # long label
      raw(badge("#{object_class} #{object.id}", label_class)) + raw(" #{text}")
    end
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
      tmp_str += "#{value[0]} <i class=\"fa fa-long-arrow-right text-info\"></i> " unless value[0].nil? or value[1].nil?

      # add minus sign if value is null now
      if value[1].nil?
        tmp_str += "<i class=\"fa fa-minus text-danger\"></i> #{value[0]}"
      end

      # add a plus sign if value wasn't set before
      if value[0].nil? or value[0].empty?
        tmp_str += "#{value[0]} <i class=\"fa fa-plus text-success\"></i> "
      end
      tmp_str += "#{value[1]}" unless value[1].nil?
      changes_arr.push(tmp_str)
    end
    raw changes_arr.to_sentence
  end

  # add link for scrolling to window top
  def link_to_top!
raw(
%Q[
<p id="scroll-top">
  <a href="#top" class="fa fa-arrow-circle-up"><span> TOP</span></a>
</p>
]
)
  end

end
