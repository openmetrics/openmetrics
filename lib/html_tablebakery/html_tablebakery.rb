# encoding: utf-8 # source files receive a US-ASCII Encoding, unless you say otherwise.
module HtmlTablebakery

  public

  # returns an html table
  # Possible options:<br/>
  #<br/>
  # :html_class - tables class attribute (will be merged with default table classes) <br/>
  # :actions - to be documented,
  def htmltable_for(collection, *args)
    table_classes = "table table-hover table-striped" # may be be expanded with :html_class
    append_actions_cell = nil
    append_join_cell = nil
    threat_as = nil # use this class to decide attributes of passed collection, may be overridden by :threat_as option
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

        if args_object.include? :threat_as
          threat_as = args_object[:threat_as]
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
    if collection.nil? or collection.empty?
      return 'None yet <i class="fa fa-meh-o"></i>'
    end

    # get attributes via first element of passed collection and apply column visibility & ordering based on presets
    sample_obj = collection.first
    obj_id = sample_obj.id
    obj_class_name = sample_obj.class.name
    obj_class_symbol = threat_as ? threat_as.underscore.to_sym : obj_class_name.underscore.to_sym
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

    # get the join attributes from associations of sample object
    join_class= nil
    join_collection=nil
    join_through_class=nil
    object_class_name = sample_obj.class.name
    object_class = object_class_name.constantize
    reflections = object_class.reflect_on_all_associations(:has_many) # :has_many, :has_one, :belongs_to
    reflections.each_with_index do |reflection, i|
      reflection_opts = reflection.options.empty? ?  '(no options)' : "(#{reflection.options.to_s})"
      #puts "#{object_class_name} »#{reflection.macro}« »#{reflection.plural_name}« #{reflection_opts}"
      # we want class that belongs to configured :join attribute name
      if append_join_cell == reflection.plural_name || append_join_cell == reflection.name
        join_class=reflection.name.to_s
      end

      # for :has_many through associations use the origin class name
      if reflection_opts.to_s.include?(":through=>:#{append_join_cell}")
        join_through_class=reflection.name.to_s
      end
    end

    # make sorting of 'actions' and join cells possible
    attr_available.push('actions') if append_actions_cell && append_actions_cell.has_value?(true)
    attr_available.push('join') if append_join_cell

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
      if attr == 'join'
        html += "<th>#{join_through_class.humanize || join_class.humanize}</th>"
      else
        html += "<th>#{attr.humanize}</th>"
      end

    end
    html += '</tr>'
    html += '</thead>'

    # generate table cells
    html += '<tbody>'
    collection.each do |item|
      html += '<tr>'

      # process cells and format value according to column name or values class name
      attr_sorted.each do |attr|

        #special treat for date columns
        case attr
          when 'actions'
            # render additional action cell?
            # TODO add more cleverness here, :destroy definitely needs special threatment, any other action could use <actionname>_<objectname>_path routes, move this into own helper method
            ac=''
            # destroy links need special handling
            if append_actions_cell && append_actions_cell[:destroy]
              classname = obj_class_name.underscore
              l = "#{classname}_path(#{item[:id]})"
              ac += link_to(raw('<span class="fa fa-times"></span> delete'), eval(l), method: :delete, class: "btn btn-default btn-xs tablebakery_delete delete_#{classname}", data: { id: obj_id, confirm: 'Are you sure?'} )
            end
            if append_actions_cell && append_actions_cell[:edit]
              l = "edit_#{obj_class_name.underscore}_path(#{item[:id]})"
              ac += link_to(raw('<span class="glyphicon glyphicon-wrench"></span> Edit'), eval(l), :class => 'btn btn-default btn-xs')
            end
            # run action should append data-id, have empty href and .run_test_plan to trigger js handlers
            if append_actions_cell && append_actions_cell[:run]
              ac += link_to(raw('<span class="glyphicon glyphicon-play-circle"></span> Run'), '#', class: 'btn btn-success btn-xs run_test_plan', data: { id: item[:id]})
            end
            if append_actions_cell && append_actions_cell[:show]
              l = "#{obj_class_name.underscore}_path(#{item[:id]})"
              ac += link_to(raw('<span class="glyphicon glyphicon-eye-open"></span> Show'), eval(l), :class => 'btn btn-default btn-xs')
            end
            html += "<td class=\"actions\">#{ac}</td>"

          # markup columns should receive syntax highlight; depends on ApplicationHelper methods!
          when 'markup'
            # try to find value of attribute "format" to decide type of markup, otherwise use text
            format = item["format"].nil? ? "text" : item["format"]
            html += "<td>#{item[attr.to_sym].html_safe? ? item[attr.to_sym] : coderay(item[attr.to_sym],format)}</td>"

          # wrap format in a nice badge; depends on ApplicationHelper methods!
          when 'format'
            html += "<td>#{badge(item[attr.to_sym], 'info')}</td>"

          # wrap type (TestCase, TestScript..) in a nice badge; depends on ApplicationHelper methods!
          when 'type'
            html += "<td>#{badge(item[attr.to_sym], 'primary')}</td>"

          when 'join'
            # render cell for join objects?
            jc=''
            if append_join_cell && join_class
              join_collection=eval("item.#{join_class}")
              # genereate link to join_class or through_class (if set)
              jc+=join_collection.map{|obj|
                join_through_class ? (link_to eval("obj.#{join_through_class.singularize}.name"), eval("obj.#{join_through_class.singularize}")) :
                    (link_to eval("obj.#{join_class.singularize}.name"), eval("obj.#{join_class.singularize}"))
              }.join(", ")
            end
            html += "<td class=\"join\">#{jc}</td>"

          when /(updated_at|created_at)/
            html+= "<td>"
            html+=I18n.localize(item[attr.to_sym], :format => :short)
            html += "</td>"

          # render just a regular text cell
          else
            html += "<td>#{item[attr.to_sym]}</td>"
         end #end case attr

      end # end attr_sorted.each

    end # end collection.each
    html += '</tr>'
    html += '</tbody>'
    html += '</table>'

    html
  end

end