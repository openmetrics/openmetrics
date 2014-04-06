module HTMLTablebakery

  public

  # returns an html table
  def htmltable_for(collection)

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


    html = '<table class="table table-hover table-striped">'
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