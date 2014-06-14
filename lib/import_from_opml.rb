class ImportFromOpml
  THREE_DAY = 24 * 60 * 60 * 3

  class << self
    def import(opml_contents, user)
      feeds_with_groups = OpmlParser.new.parse_feeds(opml_contents)

      # It considers a situation when feeds are already imported without groups,
      # so it's possible to re-import the same subscriptions.xml just to set group_id
      # for existing feeds. Feeds without groups are in 'Ungrouped' group, we don't
      # create such group and create such feeds with group_id = nil.
      #
      feeds_with_groups.each do |group_name, parsed_feeds|
        if parsed_feeds.size > 0
          group = RssCategory.where(name: group_name, user_id: user.id).first_or_create

          parsed_feeds.each { |parsed_feed| create_feed(parsed_feed, group, user) }
        end
      end
    end

    private

    def create_feed(parsed_feed, group, user)
      discoverer = FeedDiscovery.new
      result = discoverer.discover(parsed_feed[:url])
      return false unless result
      feed = RssFeed.where(url: result.feed_url).first_or_initialize
      if feed.new_record?
        feed.last_fetched = Time.now - THREE_DAY if feed.new_record?
        feed.name = parsed_feed[:name]
        feed.save
        if feed.id
          FetchFeedWorker.perform_async feed.id
        end
      end
      return false unless feed.id
      RssFeedsRssCategory.where(rss_feed_id: feed.id, rss_category_id: group.id).first_or_create
      service = Service.new
      service.service_name = 'RssFeedService'
      service.uid = user.id.to_s + "_" + feed.id.to_s
      service.access_token = feed.id
      service.provider = group.id

      service.user = user
      service.active = 1
      service.last_activity_at = Time.now
      service.last_read_time = Time.now
      service.last_unread_count = 0
      if !service.save
        service_exist = Service.where(uid: service.uid, service_name: 'RssFeedService').first
        service.id = service_exist.id
        service.save
      end

    end
  end
end
