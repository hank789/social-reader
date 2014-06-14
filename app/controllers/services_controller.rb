class ServicesController < ApplicationController
  # We need to take a raw POST from an omniauth provider with no authenticity token.
  # See https://github.com/intridea/omniauth/posts/203
  # See also http://www.communityguides.eu/articles/16
  skip_before_action :verify_authenticity_token, :only => :create

  before_action :abort_if_already_authorized, :abort_if_read_only_access, :only => :create
  before_action :check_service_active, :only => [:show]
  before_filter :set_title, only: [:index, :new, :create, :show]
  before_action :pull_service_events, :only => [:show]

  respond_to :html

  def index
    @services = current_user.services
  end
  def new
    @services = current_user.services
    @feeds = RssFeed.list
    @rss_categories = RssCategory.where("( parent_id = -1 and status = 0 and user_id = ? ) or ( parent_id = -1 and status = 1 )", current_user.id)
  end

  def create
    service = Service.initialize_from_omniauth( omniauth_hash )
    exist_service = Service.where(uid: service.uid, active: 0).first
    if exist_service
      exist_service.active = 1
      exist_service.last_activity_at = Time.now
      exist_service.uid = service.uid
      exist_service.access_token = service.access_token
      exist_service.access_secret = service.access_secret
      exist_service.info = service.info
      exist_service.save
      ServicePullWorker.perform_async(exist_service.id)
      redirect_to service_path(exist_service)
    elsif current_user.services << service
      ServicePullWorker.perform_async(service.id)
      redirect_to service_path(service)
    else
      flash[:alert] = 'there was an error connecting that service'
      redirect_to new_service_url
    end
  end

  def show
    @events = Event.load_events(current_user.id)
    @events = @events.where(service_id: @service.id).limit(50).offset(params[:offset] || 0)

    if params[:offset] == "0" && @events.first
      cookies['lasted_event_id'] = @events.first.id
    end

    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
    end
  end

  def failure
    Rails.logger.info  "error in oauth #{params.inspect}"
    flash[:alert] = 'there was an error connecting that service'
    redirect_to new_service_url
  end

  def destroy
    @service = current_user.services.find(params[:id])
    @service.active = 0
    @service.deleted_at = Time.now
    @service.save
    flash[:notice] = 'Successfully deleted authentication.'
    redirect_to new_service_url
  end

  private

  def abort_if_already_authorized
    if service = Service.where(uid: omniauth_hash['uid'], active: 1, provider: omniauth_hash['provider']).first
      flash[:alert] =  'Service has been already authorized,please try to use another account.'
      redirect_to new_service_url
    end
  end

  def abort_if_read_only_access
    if omniauth_hash['provider'] == 'twitter' && twitter_access_level == 'read'
      flash[:alert] =  'services.create.read_only_access'
      redirect_to new_service_url
    end
  end

  def omniauth_hash
    request.env['omniauth.auth']
  end

  def twitter_access_token
    omniauth_hash['extra']['access_token']
  end

  #https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema #=> normalized hash
  #https://gist.github.com/oliverbarnes/6096959 #=> hash with twitter specific extra
  def twitter_access_level
    twitter_access_token.response.header['x-access-level']
  end

  def check_service_active
    @service = Service.find(params[:id])
    if @service.active == false
      flash[:alert] =  'Invalid request'
      redirect_to new_service_url
    end
  end

  def set_title
    @title = 'Service'
  end

  def pull_service_events
    if params[:offset] == "0" && @service.last_activity_at && Time.now.to_i - @service.last_activity_at.to_time.to_i >= 90
      @service.last_activity_at = Time.now

      @service.last_unread_count = 0
      @service.last_read_time = Time.now

      @service.save
      ServicePullWorker.perform_async(@service.id)
    end
  end
end
