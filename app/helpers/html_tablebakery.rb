# encoding: utf-8 # source files receive a US-ASCII Encoding, unless you say otherwise.
module HTMLTablebakery

  public

  # returns an html table
  # Possible options:<br/>
  #<br/>
  # :html_class - tables class attribute (will be merged with default table classes) <br/>
  def htmltable_for(collection, *args)
    table_classes = "table table-hover table-striped" # may be be expanded with :html_class
    append_actions_cell = nil
    append_join_cell = nil
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

        if args_object.include? :join
          append_join_cell = args_object[:join]
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
      if (PRESETS[obj_class_symbol] && PRESETS[obj_class_symbol][a])
        eval("config_#{a.to_s} = PRESETS[obj_class_symbol][a]")
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

    # get the join attributes
    join_class= nil
    join_collection=nil
    puts "Associations:\n"
    object_class_name = sample_obj.class.name
    object_class = object_class_name.constantize
    reflections = object_class.reflect_on_all_associations(:has_many) # :has_many, :has_one, :belongs_to
    reflections.each_with_index do |reflection, i|
      puts reflection.inspect
      reflection_opts = reflection.options.empty? ?  '(no options)' : "(#{reflection.options.to_s})"
      puts "#{object_class_name} »#{reflection.macro}« »#{reflection.plural_name}« #{reflection_opts}"
      # we want class that belongs to configured :join attribute name
      if append_join_cell == reflection.plural_name || append_join_cell == reflection.name
        join_class=reflection.name.to_s
      end

      # for :has_many through associations use the origin class name
      #if reflection_opts.to_s.include?(":through=>:#{append_join_cell}")
      #  join_class=reflection.name.to_s
      #end
    end

    # create table & headings
    html = "<table class=\"#{table_classes}\">"
    html += '<thead>'
    html += '<tr>'
    attr_sorted.each do |attr|
      html += "<th>#{attr.humanize}</th>"
    end
    # append action cell header if there is any action configured
    html += '<th>Join</th>' if append_join_cell
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

      # render cell for join objects?
      jc=''
      if append_join_cell && join_class
        jc+="#{join_class}: <br>"
        join_collection=eval("item.#{join_class}")
        join_collection.each do |item|
          jc+=item.id.to_s
        end

      end
      html += "<td>#{jc}</td>" if append_join_cell

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