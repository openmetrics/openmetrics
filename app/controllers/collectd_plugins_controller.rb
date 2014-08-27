class CollectdPluginsController < ApplicationController

  def new
    @plugin = CollectdPlugin.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @plugin }
    end
  end

  def create
      @plugin = CollectdPlugin.new(params[:collectd_plugin])
      respond_to do |format|
      if @plugin.save
        format.html { redirect_to :action => "index" }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @plugins }
      end
    end
  end

  def show
    @plugin = CollectdPlugin.find(params[:id], :include => :running_collectd_plugins )
  end

  def edit
    @plugin = CollectdPlugin.find(params[:id], :include => :running_collectd_plugins )
    @systems_with_plugin = []
    @plugin.running_collectd_plugins.each do |rcp|
      rs = RunningService.find_by_id rcp.running_service_id, :include => :system
      @systems_with_plugin << rs.system unless rs.nil? 
    end
    
  end

  def update
      @plugin = CollectdPlugin.find(params[:id])        
      respond_to do |format|
        if @plugin.update_attributes(params[:collectd_plugin])
          format.html { redirect_to :action => "index" }
          flash[:notice] = "The plugin has been saved!"
        else
          format.html { redirect_to :action => "edit" }
          flash[:notice] = "Saving the plugin has been failed"
        end
      end
  end

  def index
    @plugins = CollectdPlugin.find(:all)
  end

  def destroy
    @plugin = CollectdPlugin.find_by_id(params[:id])
    @plugin.destroy
    respond_to do |format|
      flash[:notice] = "Collectd plugin has been deleted"
      format.html { redirect_to(collectd_plugins_path) }
    end
  end

end
