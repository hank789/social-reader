class Admin::RssFeedsController < Admin::ApplicationController

  def index

    @rss_feeds_rss_categories = RssFeedsRssCategory.list
    @feeds = RssFeed.list

  end

  def new

  end

  def create

  end

end
