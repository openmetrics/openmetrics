class SearchesController < ApplicationController


  def search
    @search_string = params[:q].strip if params[:q]
    limit = 3 if false
    if @search_string != nil
      q = "%#{@search_string}%"

      @test_plans = TestPlan.where("name ilike ? or description ilike ?", q, q)
      @systems = System.where("name ilike ? or fqdn ilike ?", q, q)
      @services = Service.where("name ilike ?", q)

    end

    if request.xhr?
      render :layout => false, :action => 'search_ajax.html.erb'
    end

  end

end