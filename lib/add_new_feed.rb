class AddNewFeed
  THREE_DAY = 24 * 60 * 60 * 3

  def self.add(url, user, group_id = nil, discoverer = FeedDiscovery.new, repo = RssFeed)
    result = discoverer.discover(url)
    return false unless result

    feed = repo.where(url: result.feed_url).first_or_initialize
    return_result = 0
    if feed.new_record?
      feed.name = result.title
      feed.last_fetched = Time.now - THREE_DAY
      feed.save
      if feed.id
        FetchFeedWorker.perform_async feed.id
      end
    end
    return false unless feed.id
    service = Service.where(uid: user.id.to_s + "_" + feed.id.to_s, service_name: 'RssFeedService').first_or_initialize
    if service.new_record?
      return_result = 1
      service.access_token = feed.id
      if group_id
        service.provider = group_id
      else
        group = RssCategory.where(name: "Ungrouped", user_id: user.id).first_or_create
        service.provider = group.id
      end
      service.user = user
      service.active = 1
      service.last_activity_at = Time.now
      service.last_read_time = Time.now
      service.last_unread_count = 0
      service.save
    end

    if return_result == 0
      return 0
    end
    feed
  end
end