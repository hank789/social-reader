class Admin::DashboardController < Admin::ApplicationController
  def index
    @services = Service.order("created_at DESC").limit(15)
    @users = User.order("created_at DESC").limit(15)
    @rss_feeds = RssFeed.all
    #@groups = Group.order("created_at DESC").limit(10)
  end
end
