class ServicesController < ApplicationController
  # We need to take a raw POST from an omniauth provider with no authenticity token.
  # See https://github.com/intridea/omniauth/posts/203
  # See also http://www.communityguides.eu/articles/16
  skip_before_action :verify_authenticity_token, :only => :create
  before_action :authenticate_user!
  before_action :abort_if_already_authorized, :abort_if_read_only_access, :only => :create
  before_action :check_service_active, :only => [:edit , :update]

  respond_to :html

  def index
    @services = current_user.services
  end
  def new
    @services = current_user.services
  end
  def create
    service = Service.initialize_from_omniauth( omniauth_hash )
    exist_service = Service.where(uid: service.uid, active: 0).first
    if exist_service
      exist_service.active = 1
      exist_service.save
      redirect_to edit_service_path(exist_service)
    else if current_user.services << service
      redirect_to edit_service_path(service)
    else
      flash[:alert] = 'there was an error connecting that service'
      redirect_to_origin
    end

    end
  end

  def edit

  end

  def update
    @service.priority = params[:"#{@service.provider}_service"][:priority_level]
    @service.visibility_level = params[:"#{@service.provider}_service"][:visibility_level]
    if @service.save
      flash[:notice] = 'Service was successfully saved.'
    end
    redirect_to edit_service_url(@service)
  end

  def get_tweets
    service = Service.find_by_id(1)
    tweets=service.get_home_timeline_tweets(service.since_id)
    last_tweet = tweets.first
    if last_tweet && last_tweet.id
      service.since_id = last_tweet.id
      service.save
    end

    tweets.each do |tweet|
      service.post tweet
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
    if service = Service.where(uid: omniauth_hash['uid'], active: 1).first
      flash[:alert] =  'services.create.already_authorized'
      redirect_to_origin
    end
  end

  def abort_if_read_only_access
    if omniauth_hash['provider'] == 'twitter' && twitter_access_level == 'read'
      flash[:alert] =  'services.create.read_only_access'
      redirect_to_origin
    end
  end

  def redirect_to_origin
    if origin
      redirect_to origin
    else
      render(text: "<script>window.close()</script>")
    end
  end

  def origin
    request.env['omniauth.origin']
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
end
