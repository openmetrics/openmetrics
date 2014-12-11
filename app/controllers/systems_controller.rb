class SystemsController < ApplicationController

  before_filter :get_object, only: [:show, :edit, :update, :destroy]
  before_filter :inject_logged_user, only: [:update]

  def index
    add_breadcrumb 'Systems List'
    @systems = System.includes(:running_services)
    respond_with(@systems)
  end

  def new
    # passing to new causes formbakery placeholders to appear
    @system = System.new(name: 'my example host', fqdn: 'host.example.com')
    @ip_lookup = IpLookup.new(:target => 'www.example.com or 127.0.0.1/32')
    @recent_ip_lookups = IpLookup.recent.where(user: current_user)
  end

  def create
    @system = System.new(system_params)
    if @system.save
      @system.create_activity :create, :owner => current_user
      flash[:success] = "System saved."
      redirect_to system_path(@system)
    else
      flash[:warn] = "Oh snap! That didn't work."
      redirect_to_anchor_or_back
    end
  end

  # POST /systems/scan
  # initiates background process IpLookupWorker to start nmap scan on given target
  # creates an IpLookup object when finished for further use
  def scan
    i = IpLookup.new(ip_lookup_params)
    i.user_id = current_user.id
    begin
      if i.save
        i.create_activity :create, :owner => current_user
        flash[:success] = 'IpLookup scheduled successfully.'
      else
        flash[:warn] = 'Oh snap! Scheduling IpLookup on that target failed. ;('
      end
    rescue
      logger.error 'Failed to schedule job on IpLookupWorker'
      flash[:error] = "That IpLookup schedule didn't work."
    ensure
      redirect_to_anchor_or_back
    end
  end

  # POST /systems/profile
  def profile
    sl = SystemLookup.new(system_lookup_params)
    sl.user_id = current_user.id
    begin
      if sl.save
        sl.create_activity :create, :owner => current_user
        flash[:success] = 'System audit scheduled successfully.'
      else
        flash[:warn] = 'Oh snap! Scheduling  on that System failed. ;('
      end
    rescue
      logger.error 'Failed to schedule job on SystemLookupWorker'
      flash[:error] = "That SystemLookup schedule didn't work."
      ensure
      redirect_to_anchor_or_back
    end
  end

  def show
    @services = Service.all
    @system_metrics = @system.metrics.group_by(&:plugin)
    @system_events = PublicActivity::Activity.order("created_at desc").where(trackable_type: 'System', trackable_id: @system.id)
    add_breadcrumb @system.name, 'system'
  end

  def edit
    add_breadcrumb "edit #{@system.name}", "system"
    @services = Service.all
    @collectd_plugins = CollectdPlugin.all
  end

  def update
    detect_changes
    if @system.update!(system_params)
      inject_logged_user
      changes = Secretary::Version.where(versioned_type: 'System', versioned_id: @system.id, user_id: current_user.id)
      activity_params = if changes.any? and attr_changed?
                          last_change = changes.last
                          { :description => last_change.description, :changes => last_change.object_changes }
                        else
                          {}
                        end

      @system.create_activity :update, :owner => current_user, :parameters => activity_params
      flash[:success] = "System updated."
    else
      flash[:warn] = 'Something went wrong while updating system.'
    end
    redirect_via_turbolinks_to :back
  end

  def destroy
    if @system.destroy
      flash[:notice] = "Successfully destroyed system."
      redirect_to :action => "index"
    else
      flash[:error] = 'Failed to delete system.'
    end
  end


  private

  def get_object
    @system = System.friendly.find(params[:id])
  end

  # Use this method to whitelist the permissible parameters. Example:
  # params.require(:person).permit(:name, :age)
  # Also, you can specialize this method with per-user checking of permissible attributes.
  def system_params
    params.require(:system).permit(:name, :fqdn, :description, :cidr, :sshuser, :operating_system, :operating_system_flavor,
                                   running_services_attributes: [:id, :_destroy, :service_id, :fqdn, :description],
                                   running_collectd_plugins_attributes: [:id, :_destroy, :running_service_id, :collectd_plugin_id]
    )
  end

  def ip_lookup_params
    params.require(:ip_lookup).permit(:target)
  end

  def system_lookup_params
    params.require(:system_lookup).permit(:system_id)
  end

  # save user_id within model changes
  # https://github.com/SCPR/secretary-rails#tracking-users
  def inject_logged_user
    @system.logged_user_id = current_user.id
  end

  def detect_changes
    @changed = []
    system_params.each do |param|
      p_name = param[0]
      p_value = param[1]
      next if p_value.is_a? Hash # TODO detect changes to running_services and running_collectd_plugins aswell
      @changed << p_name if @system.send(p_name) != p_value
    end

  end

  def attr_changed?
    @changed.any?
  end

end
