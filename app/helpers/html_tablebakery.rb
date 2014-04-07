module HTMLTablebakery

  public

  # returns an html table
  # Possible options:<br/>
  #<br/>
  # :html_class - tables class attribute (will be merged with default table classes) <br/>
  def htmltable_for(collection, *args)
    table_classes = "table table-hover table-striped" # may be be expanded with :html_class
    # *args is an Array and not a hash, so we need to make it a little more
    # usable first! Scan for known options and use them
    args.each do |args_object|
      if args_object.is_a? Hash

        if args_object.include? :html_class
          table_classes = table_classes+' '+args_object[:html_class]
        end

      end
    end

    attr_ignore = []
    attr_hide = []
    attr_available = []

    # get attributes via first element of passed collection
    if collection.empty?
      return "None"
    else
      collection.first.attributes.each_key {|attr| attr_available.push(attr) unless attr_ignore.include?(attr) || attr_hide.include?(attr) }
    end

    attr_order = attr_available.sort
    attr_sorted = attr_order & attr_available


    html = "<table class=\"#{table_classes}\">"
    html += '<thead>'
    html += '<tr>'

    attr_sorted.each do |attr|
      html += "<th>#{attr}</th>"
    end

    html += '</tr>'
    html += '</thead>'
    html += '<tbody>'
    collection.each do |val|
      # generate table cells
      html += '<tr>'
      attr_sorted.each do |attr|
        # special treat for type (=date) and partner_netto (+gameserver revs)column
        # case attr
        #   when "type"
        #     html += "<td>"
        #     if resolution == "monthly"
        #       the_date = Date.parse(val[attr.to_sym].gsub(/.*PaymentStats(....)(..)/, '\1/\2'))
        #       html+=I18n.localize(the_date, :format => :long_my)
        #     else
        #       the_date = Date.parse(val[attr.to_sym].gsub(/DailyPaymentStats(.*)/, '\1'))
        #       html+=I18n.localize(the_date, :format => :short)
        #     end
        #     html += "</td>"
        #   else
        #     html += "<td class=\"#{attr_type(attr,val[attr.to_sym])}\">#{val[attr.to_sym]}</td>"
        # end
        html += "<td>#{val[attr.to_sym]}</td>"
      end
    end
    html += '</tr>'
    html += '</tbody>'
    html += '</table>'

    html
  end

end