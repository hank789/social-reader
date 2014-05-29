class Admin::RssFeedsController < Admin::ApplicationController

  def index

    @rss_feeds_rss_categories = RssFeedsRssCategory.list
    @feeds = RssFeed.list

  end

  def new

  end

  def create

  end

  def fetch_posts
    FetchFeedWorker.perform_async
    redirect_to admin_rss_feeds_path
  end

end
