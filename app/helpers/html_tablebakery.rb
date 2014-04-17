# encoding: utf-8 # source files receive a US-ASCII Encoding, unless you say otherwise.
module HtmlTablebakery

  public

  # returns an html table
  # Possible options:<br/>
  #<br/>
  # :html_class - tables class attribute (will be merged with default table classes) <br/>
  def htmltable_for(collection, *args)
    table_classes = "table table-hover table-striped" # may be be expanded with :html_class
    append_actions_cell = nil
    # *args is an Array and not a hash, so we need to make it a little more
    # usable first! Scan for known options and use them
    args.each do |args_object|
      if args_object.is_a? Hash

        if args_object.include? :html_class
          table_classes = table_classes+' '+args_object[:html_class]
        end

        if args_object.include? :actions
           append_actions_cell = args_object[:actions]
        end

      end
    end

    attr_ignore = []
    attr_hide = []
    attr_available = []
    attr_order = []
    config_attr_ignore = nil
    config_attr_order = nil

    # test collection for validity
    if collection.empty?
      return "No collection passed"
    end

    # get attributes via first element of passed collection and apply column visibility & ordering based on presets
    sample_obj = collection.first
    obj_id = sample_obj.id
    obj_class_name = sample_obj.class.name
    obj_class_symbol = obj_class_name.underscore.to_sym
    # resolve default presets (ignore and order)
    [:attr_order, :attr_ignore].each do |a|
      if (TABLEBAKERY_PRESETS[obj_class_symbol] && TABLEBAKERY_PRESETS[obj_class_symbol][a])
        eval("config_#{a.to_s} = TABLEBAKERY_PRESETS[obj_class_symbol][a]")
      end
    end

    # any attr to ignore?
    attr_ignore.concat(config_attr_ignore).uniq if config_attr_ignore

    # which attr are available for collection sample?
    sample_obj.attributes.each_key {|attr| attr_available.push(attr) unless attr_ignore.include?(attr) || attr_hide.include?(attr) }

    # ordering
    #attr_order = attr_available.sort
    if config_attr_order
      attr_diff = attr_available.sort - config_attr_order.sort
      attr_sorted = (config_attr_order & attr_available) + attr_diff
    else
      attr_sorted = attr_available.sort
    end

    # create table & headings
    html = "<table class=\"#{table_classes}\">"
    html += '<thead>'
    html += '<tr>'
    attr_sorted.each do |attr|
      html += "<th>#{attr.humanize}</th>"
    end
    # append action cell header if there is any action configured
    html += '<th>Actions</th>' if append_actions_cell && append_actions_cell.has_value?(true)
    html += '</tr>'
    html += '</thead>'

    # generate table cells
    html += '<tbody>'
    collection.each do |item|
      html += '<tr>'

      # process cells
      attr_sorted.each do |attr|
        #special treat for date columns
        case attr
          when /(updated_at|created_at)/
            html+= "<td>"
            html+=I18n.localize(item[attr.to_sym], :format => :short)
            html += "</td>"
          else
            html += "<td>#{item[attr.to_sym]}</td>"
         end

      end

      # render additional action cell?
      ac=''
      if append_actions_cell && append_actions_cell[:show]
        show_link = "#{obj_class_name.underscore}_path(#{item[:id]})"
        ac += link_to raw('<span class="glyphicon glyphicon-eye-open"></span> show'), eval(show_link), :class => 'btn btn-default btn-xs'
      end
      if append_actions_cell && append_actions_cell[:edit]
        edit_link = "edit_#{obj_class_name.underscore}_path(#{item[:id]})"
        ac += link_to raw('<span class="glyphicon glyphicon-wrench"></span> Edit'), eval(edit_link), :class => 'btn btn-default btn-xs'
      end
      html += "<td>#{ac}</td>" if append_actions_cell
    end
    html += '</tr>'
    html += '</tbody>'
    html += '</table>'

    html
  end

end