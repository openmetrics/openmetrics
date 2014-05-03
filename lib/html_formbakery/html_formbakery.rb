# encoding: utf-8 # source files receive a US-ASCII Encoding, unless you say otherwise.
module HtmlFormbakery

  public
  def info_for(object)
    puts "Object class_name: #{object.class.name}\n"
    puts "Attributes:"
    attributes = object.attributes
    attributes.each do |attribute|
      attr, value = attribute[0], attribute[1]
      puts "»#{attr}« has a value of »#{value}« and is a »#{value.class}«"
      # check for linked subobjects
      if attr[((attr.length)-3)..attr.length].include? "_id"
        puts "    "
        # lets see, if we can get info in this too!
        object_class_name = attr[0..((attr.length)-4)]
        caller = object_class_name.camelize # make CamelCase
        puts "... and it is a linked Object of class #{caller}"

        # TODO Check value to be really a FixNum/Integer
        newobj = eval("#{caller}.find #{value} ")
        puts "\n\n . . Subobject: . . "
        self.info_for newobj
        puts " . . . . . . . . . ."
      end

      # serialized data?
      if value.is_a? Hash
        self.form_for_hash value
      end
    end

    # analyze and print associations (:has_many only)
    puts "Associations:\n"
    object_class_name = object.class.name
    object_class = object_class_name.constantize
    reflections = object_class.reflect_on_all_associations(:has_many) # :has_many, :has_one, :belongs_to
    reflections.each_with_index do |reflection, i|
        #puts reflection.inspect
        reflection_opts = reflection.options.empty? ?  '(no options)' : "(#{reflection.options.to_s})"
        puts "#{object_class_name} »#{reflection.macro}« »#{reflection.plural_name}« #{reflection_opts}"
    end

    nil
  end

  # Returns a html-form for the given RAILS-object
  # Possible options:<br/>
  #<br/>
  # :caption - form legend value of created form <br/>
  # :nested - does not create neiter 'form'-tags, nor buttons and csrf token<br/>
  # :only (array) - only create inputs for the given fields<br/>
  # :except (array) - create all inputs except for the given fields<br/>
  # :include_linked_objects - if set, FB will try to create fields for linked objects too.<br/>
  # :include_join_tables (array) - EXPERIMENTAL include join tables linking to the object in form of lists<br/>
  # :html_class - form class attribute (will be merged with default form classes) <br/>
  # :help_text ( object ) - help text for form fields
  # :within_tab - set this to true if form is rendered within a ui tab. as a result a hidden input _anchor with name of current page anchor is inserted to form
  # <br/>
  # Not implemented:<br/>
  # :include_subobjects<br/>
  # :include_timestamps<br/>
  #
  def htmlform_for(object, *args)
    default_action = "update"
    default_method = "post"
    object_name = object.class.to_s.underscore # makes "RunningService" become "running_service"
    is_new_object = object.id.nil? # affects placeholder behavoir
    list_only = nil
    list_except = nil
    list_include_join_tables = nil
    caption = nil
    submit_text = nil
    help_text = nil
    nested = false
    include_page_anchor = false
    form_classes = "form-horizontal" # may be be expanded with :html_class
    form_id="#{object_name.pluralize}_#{is_new_object ? 'new' : 'update'}" # default html id, e.g. systems_new
    # TODO proper placeholder control; currently if a object is new (Object.id ==nil) placeholders are set

    # *args is an Array and not a hash, so we need to make it a little more
    # usable first! Scan for known options and use them
    args.each do |args_object|
      if args_object.is_a? Hash

        if args_object.include? :only
          list_only = args_object[:only]
        end

        if args_object.include? :except
          list_except = args_object[:except]
        end

        if args_object.include? :include_join_tables
          list_include_join_tables = args_object[:include_join_tables]
        end

        if args_object.include? :caption
          caption = args_object[:caption]
        end

        if args_object.include? :html_class
          form_classes = form_classes+' '+args_object[:html_class]
        end

        if args_object.include? :submit_text
          submit_text = args_object[:submit_text]
        end

        if args_object.include? :help_text
          help_text = args_object[:help_text]
        end

        if args_object.include? :nested
          nested = args_object[:nested]
        end

        if args_object.include? :within_tab
          include_page_anchor = args_object[:within_tab]
        end

      end
    end

    html_result = ''
    js = ''

    # start the form
    html_result << "<form class=\"#{form_classes}\" role=\"form\" method=\"#{default_method}\" id=\"#{form_id}\" action=\"/#{object_name.pluralize}/#{object.id}\">" unless nested

    addtional_fields = "" # here go the fields for linked subobjects

    attributes = object.attributes
    html_result << "<fieldset>"
    html_result << "<legend>#{caption || object.class.to_s}</legend>" if caption
    attributes.each do |attribute|
      #puts "Attribute: »#{attribute[0]}« has a value of »#{attribute[1]}« and is a »#{attribute[1].class}«"
      field_symbol = attribute[0].to_sym
      field_value = attribute[1]

      # help text available?
      # TODO this crashes if ':help_text' => l("om.some.path") does dont exist in any language file
      h=nil
      if help_text
        unless help_text[field_symbol].nil?
          h=help_text[field_symbol]
        end
      end

      # just given list_only attributes
      unless list_only.nil?
        if list_only.include? field_symbol
          html_result << '<div class="form-group">'
          html_result << input_for(object_name, attribute[1], attribute[0], is_new_object, h)
          html_result << '</div>'
        end
      end

      # all attributes except the given ones
      if !list_except.nil? and list_only.nil?
        unless list_except.include? field_symbol
          html_result << '<div class="form-group">'
          html_result << input_for(object_name, attribute[1], attribute[0], is_new_object, h)
          html_result << '</div>'
        end
      end

      # show all attributes
      if list_only.nil? and list_except.nil?
        html_result << '<div class="form-group">'
        html_result << input_for(object_name, attribute[1], attribute[0], is_new_object, h)
        html_result << '</div>'
      end

      # TODO doesnt seem to be good yet
      # nested attributes
      if args.include? :include_linked_objects
        # check for linked subobjects
        if attribute[0][((attribute[0].length)-3)..attribute[0].length].include? "_id"
          object_class_name = attribute[0][0..((attribute[0].length)-4)]
          caller = object_class_name.camelize # make CamelCase

          newobj = eval("#{caller}.find(#{attribute[1]})")
          #html_result << " . . subobject: . . "
          #html_result << "</fieldset>"
          addtional_fields += self.form_for newobj, true
          #html_result << "<fieldset>"
          #html_result << " . . . . . . . . . ."
        end
      end
      # serialized data?
      if attribute[1].is_a? Hash
        self.form_for_hash attribute[1]
      end
    end
    html_result << "</fieldset>"
    html_result << addtional_fields

    unless list_include_join_tables.nil?
      html_result << join_table_input(object, object_name, list_include_join_tables)
    end

    unless nested
      # add csrf token
      html_result << "<input type=\"hidden\" value=\"#{form_authenticity_token}\" name=\"authenticity_token\">"

      # buttons
      html_result << '<div class="form-group"><label class="col-md-4 control-label"></label><div class="col-md-4">'
      if is_new_object
        html_result << "<button type=\"submit\" class=\"btn btn-default btn-success bt-lg pull-right\">#{submit_text||I18n.t("om.forms.submit_text.new")}</button>"
      else
        html_result << "<input type=\"hidden\" value=\"put\" name=\"_method\">"
        html_result << "<button type=\"submit\" class=\"btn btn-default\">#{submit_text||I18n.t("om.forms.submit_text.new")}</button>"
      end
      html_result << '</div></div>'
      html_result << '</form>'
    end

    # append some javascript
    js += js_input_for_page_anchor(form_id) if include_page_anchor
    return html_result+js
  end


  protected

  # passed hidden input field 'page_anchor' with form to make bounce back to ui panel possbile
  # this is only useful in conjunction with :within_tab option
  def js_input_for_page_anchor(form_id)
    "
    <script type=\"text/javascript\">
      $(function() {
      var form = $('##{form_id}');
      if ( form.length ) {
        form.submit(function( event ) {
          var page_anchor = window.location.hash;
          form.append('<input name=\"anchor\" type=\"hidden\" value=\"'+page_anchor+'\">');
          return;
        });
      }
      });
    </script>
    "
  end

  def wrap_label(html, labeltext, helptext)
    l =  "<label class=\"col-md-4 control-label\" for=\"textinput\">#{labeltext.humanize}</label>"
    l << '<div class="col-md-4">'
    l << html
    # help text set?
    l << "<span class=\"help-block\">#{helptext}</span>" unless helptext.nil?
    l << '</div>'
    l
  end

  # TODO: Hash in a Hash in a Hash?!
  def form_for_hash(hashobject)
    hashobject.each do |item|
      if (item.is_a? Array) and (item.size == 2)
        puts "          Serialized Value: »#{item[0]}« value »#{item[1]}« is a »#{item[1].class}«"
      end
    end
  end

  def input_for(formholder_object_name,object,object_name,is_new_object, helptext)
    result = ''
    if object.is_a? String

      result += '<input type="text" class="form-control input-md" '
      # if object is new (id == nil) add value as placeholder
      if is_new_object
        result += "placeholder=\"#{object.to_s}\" name=\"#{formholder_object_name}[#{object_name}]\" id=\"#{formholder_object_name}_#{object_name}\">"
      else
        result += "value=\"#{object.to_s}\" name=\"#{formholder_object_name}[#{object_name}]\" id=\"#{formholder_object_name}_#{object_name}\">"
      end
      return wrap_label(result, object_name, helptext)
    end

    if object.is_a? Fixnum
      # Note: this could be an ID linked to another Object/Objectlist, this could be made a 'select' instead!

      # check if it is an ID_field
      if object_name[((object_name.length)-3)..object_name.length].include? "_id"
        # it is an ID_field
        # We suppose it is a link to another set of Objects, so we obtain a list containing them!
        object_class_name = object_name[0..((object_name.length)-4)]
        caller = object_class_name.camelize # make CamelCase
        list = eval("#{caller}.find(:all, :select => \"name,id\")") # we assume the objects have a 'name'
        result += "<select name=\"[#{object_name}(1i)]\" id=\"#{object_name}_1i\">"
        list.each do |item|
          result += "<option #{"selected=\"selected\"" unless item.id != object} value=\"#{item.id}\">#{item.name}</option>"
        end
        result += "</select>"

      else
        # just a normal Integer!
        result += "<input type=\"text\" value=\"#{object.to_s}\" name=\"#{formholder_object_name}[#{object_name}]\" id=\"#{formholder_object_name}_#{object_name}\">"
      end
      return wrap_label(result, object_name,helptext)
    end
    if object.is_a? Time
      # usually you wont need to change this, but we can generate an input too:
      # TODO : BROKEN!
      #result += ActionView::Helpers::DateHelper.select_datetime object
      return wrap_label(result, object_name, helptext)
    end

    # unknown object type
    result += '<input type="text" class="form-control input-md" '
      if is_new_object
        result += "value=\"\" name=\"#{formholder_object_name}[#{object_name}]\" id=\"#{formholder_object_name}_#{object_name}\">"
      else
        result += "placeholder=\"unknown ObjectType for input: #{object.class}\" name=\"#{formholder_object_name}[#{object_name}]\">"
      end

    return wrap_label(result, object_name, helptext)
  end

  def join_table_input(object, object_name, tablename)
    linked_objects = eval("#{tablename.camelize}.find(:all, :conditions => { :#{object_name}_id => #{object.id.to_s}})")
    possible_objects = eval("#{tablename.camelize}.find(:all)")

    has_name = false
    object_class_name = ""
    caller = ""
    # has object a name?
    #if linked_objects.first.has_attribute? "name"
    #  has_name = true
    #else
    #  has_name = false
    #end

    possible_objects.first.atrributes.each do |attribute|
      if attribute[0][((attribute[0].length)-3)..attribute[0].length].include? "_id"
        # this is one link from the join table, lets see if it is the right one
        if attribute[0].include? object_name
          # not this name!
        else
          # this one is right! if only two id_links are present... which should be in a join table
          # lets see, if we can get info in this too!
          object_class_name = attribute[0][0..((attribute[0].length)-4)]
          #puts "    - Classname = #{object_class_name}"
          caller = object_class_name.camelize # make CamelCase

          #newobj = eval("#{caller}.find(#{attribute[1]})")
        end
      end
    end

    result = ""
    result += "<select multiple>"
    linked_objects.each do |object|
      name = "unnamed"
      if has_name
        linked_id = 0
        object.attributes.each do |attribute|
          if attribute[0][((attribute[0].length)-3)..attribute[0].length].include? "_id"
            # this is one link from the join table, lets see if it is the right one
            if attribute[0].include? object_name
              # not this name!
            else
              # this one is right! if only two id_links are present... which should be in a join table
              # lets see, if we can get info in this too!
              object_class_name = attribute[0][0..((attribute[0].length)-4)]
              #puts "    - Classname = #{object_class_name}"
              caller = object_class_name.camelize # make CamelCase

              newobj = eval("#{caller}.find(#{attribute[1]})")
            end
          end
        end
        #newobj = eval("#{caller}.find(#{object.})")
      end
      result += "<option value=\"#{object.id}\"> #{object.name if has_name} #{object.id.to_s} </option>"
    end
    result += "</select>"

    result += "<select multiple>"
    possible_objects.each do |object|
      result += "<option value=\"#{object.id}\"> #{object.name  if has_name} #{object.id.to_s} </option>"
    end
    result += "</select>"

    return result
  end

end
