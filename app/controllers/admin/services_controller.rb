class Admin::ServicesController < Admin::ApplicationController

  def index
    @services = Service.filter(params[:filter])
    @services = @services.by_user.page(params[:page])
    @rss_feeds = RssFeed.all
  end

end
