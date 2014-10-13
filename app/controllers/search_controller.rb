class SearchController < ApplicationController


  def search
    @search_string = params[:q].strip if params[:q]
    limit = 3 if false
    if @search_string != nil
      q = "%#{params[:q]}%"


      # @partners = []
      # p = @current_user.partner_logins.find(:all, :include => [:partner])
      # unless p.nil?
      #   p.each do |x|
      #     @partners.push(x) if x.partner.name.match(/#{@search_string}/i)
      #   end
      # end
      #
      # @cids = []
      # cids = Cid.find(:all, :conditions => ["cid ILIKE ?", query])
      # cids.each do |cid|
      #   pl = @current_user.partner_logins.find_by_partner_id cid.partner.id
      #   unless pl.nil?
      #     pl_cid = {:pl => pl, :cid => cid}
      #     @cids.push(pl_cid)
      #
      #   end
      # end
      # @cids.uniq! { |x| x[:p] }

      @test_plans = TestPlan.where("name ilike ? or description ilike ?", q, q)
      @systems = System.where("name ilike ? or fqdn ilike ?", q, q)
      @services = Service.where("name ilike ?", q)

      #@services = Service.where(:all, :limit => limit, :conditions => ["(name ILIKE ?) OR (dns_name ILIKE ?) OR (typ ILIKE ?) OR (description ILIKE ?)", query, query, query, query])

      # @dashboards = Dashboard.find(:all, :limit => limit, :conditions => ["(name ILIKE ?) ", query])
      #
      # @events = Event.find(:all, :limit => limit, :conditions => ["(preferences ILIKE ?)", query])
    end

    if request.xhr?
      render :layout => false, :action => 'search_ajax.html.erb'
    end

  end

end