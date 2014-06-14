class RssfeedsController < ApplicationController
  before_filter :set_title, only: [:index, :new, :add_rss_feed, :edit, :update]

  respond_to :html

  def index
    @services = current_user.services
  end
  def new
    @services = current_user.services
    @feeds = RssFeed.list
    @rss_categories = RssCategory.parent_category
  end

  def edit

  end
  def rss
    @title = 'RSS'
    @feed = RssFeed.new
  end

  def create_rss

  end

  def update
    @rss_child_categories = RssCategory.child_category(params[:id])
    if params[:service].present? && params[:service][:select_feed].present?
      cids = [params[:id],params[:service][:select_feed]]
    else
      cids = RssCategory.child_category(params[:id]).pluck(:id)
      cids += [params[:id]]
    end
    rss_feed_ids = RssFeedsRssCategory.get_rss_feeds_by_cid(cids).pluck(:id)
    rss_feeds = RssFeed.where(id: rss_feed_ids)
    current_user_services = Service.unscoped.where(user_id: current_user.id, active: [0,1])
    if current_user_services.any?{|service| service.provider == params[:id].to_s}
      if params[:service].present? && params[:service][:select_feed].present?
        Service.unscoped.where(user_id: current_user.id, active: [0,1], provider: params[:id]).update_all(active: 0)
        if current_user_services.any?{|service| service.nickname == params[:service][:select_feed].to_s}
          Service.unscoped.where(user_id: current_user.id, active: [0,1], nickname: params[:service][:select_feed]).update_all(active: 1)
        else
          save_service(rss_feeds)
        end
      else
        Service.unscoped.where(user_id: current_user.id, active: [0,1], provider: params[:id]).update_all(active: 1)
      end
    else
      save_service(rss_feeds)
    end
    flash[:notice] = 'Service was successfully saved.'
    redirect_to "/services/rssfeeds/#{params[:id]}"
  end

  def add_rss_feed
    @rss_category = RssCategory.find(params[:id])
    @rss_child_categories = RssCategory.child_category(params[:id])
    @service = Service.new
    @rssfeed = RssFeed.new
    if current_user.services.any?{|service_item| service_item.provider == @rss_category.id.to_s}
      service_item = Service.where(user_id: current_user.id, provider: params[:id]).first
      @service.id = params[:id]
      @service.nickname = service_item.nickname
    else
      @service.nickname = "5"
    end

  end

  def add_feed
    @feed_url = params[:feed_url]
    @feed_group = params[:feed_group]
    feed = AddNewFeed.add(@feed_url, current_user, @feed_group)

    if feed == 0
      flash[:alert] = 'Feed already subscribed'
      render text: 2
    elsif feed
      flash[:notice] = 'Feed successfully added'
      render text: 1
    else
      flash[:alert] = 'Feed not found'
      render text: 3
    end
  end

  def delete_feed
    Service.unscoped.where(user_id: current_user.id, access_token: params[:id]).update_all(active: 0)
    flash[:notice] = 'Feed successfully removed'
    render text: 1
  end

  def apply_import
    ImportFromOpml.import(params["opml_file"].read, current_user)
    flash[:notice] = 'Your feeds was successfully imported.'
    redirect_to new_service_url
  end

  def destroy
    Service.unscoped.where(user_id: current_user.id, provider: params[:id]).update_all(active: 0)
    flash[:notice] = 'Successfully removed service.'
    redirect_to new_service_url
  end

  private
  def set_title
    @title = 'Service'
  end

  def save_service(rss_feeds)
    rss_feeds.each do |feed|
      service = Service.new
      service.service_name = 'RssFeedService'
      service.uid = current_user.id.to_s + "_" + feed.id.to_s
      service.access_token = feed.id
      service.provider = params[:id]
      if params[:service].present? && params[:service][:select_feed].present?
        service.nickname = params[:service][:select_feed]
      end
      service.user = current_user
      service.active = 1
      service.last_activity_at = Time.now
      service.last_read_time = Time.now
      service.last_unread_count = 0
      service.save
      ServicePullWorker.perform_async(service.id)
    end
  end
end
