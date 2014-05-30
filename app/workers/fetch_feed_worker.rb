class FetchFeedWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(feed_id=nil)
    if feed_id
      fetch_feed(feed_id)
    else
      feeds = RssFeed.all
      feeds.each do |feed|
        fetch_feed(feed.id)
      end
    end
    FetchFeedWorker.perform_in(3.hours)
  end

  def log(message)
    Gitlab::GitLogger.info("FetchFeedWorker: #{message}")
  end

  def fetch_feed(feed_id)
    feed = RssFeed.find(feed_id)
    raw_feed = Feedjira::Feed.fetch_and_parse(feed.url, if_modified_since: feed.last_fetched, timeout: 60, max_redirects: 2)
    count = 0
    if raw_feed == 304 || raw_feed == 0
      log("#{feed.url} has not been modified since last fetch")
    else
      new_entries_from(raw_feed,feed).each do |entry|
        feed.last_fetched_id = entry.id unless count >= 1
        count += 1
        Post.add_rss_feed_post(entry, feed)
      end
      RssFeed.update_last_fetched(feed, raw_feed.last_modified)
    end
  end

  private
  def new_entries_from(raw_feed,feed)
    return [] if raw_feed.is_a? Integer
    return [] if raw_feed.last_modified &&
        raw_feed.last_modified < feed.last_fetched

    stories = []
    raw_feed.entries.each do |story|
      #break if feed.last_fetched_id && story.id == feed.last_fetched_id
      stories << story unless story.published &&
          story.published < feed.last_fetched
    end
    stories
  end

end