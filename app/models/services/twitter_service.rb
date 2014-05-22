class TwitterService < Service
  include Rails.application.routes.url_helpers

  MAX_CHARACTERS = 140
  SHORTENED_URL_LENGTH = 21
  LINK_PATTERN = %r{https?://\S+}

  def provider
    "twitter"
  end

  def post tweet
    author = Author.new
    author.provider = self.provider
    author.name = tweet.user.name
    author.guid = tweet.user.id
    author.slug = tweet.user.screen_name
    author.remote_avatar_url = tweet.user.profile_image_url.to_s
    author.description = tweet.user.description.to_s
    author.profile_url = "https://twitter.com/#{tweet.user.screen_name.to_s}"
    author.data = tweet.user
    if !author.save
      author_exist = Author.find_last_by_provider_and_guid(self.provider,tweet.user.id)
      author.id = author_exist.id
      author.save
    end


    post = Post.new
    post.description = tweet.full_text
    post.author_id = author.id
    post.guid = tweet.id
    post.provider = self.provider
    post.link = tweet.uri.to_s
    post.favourite_count = 0
    post.created_at = tweet.created_at
    post.updated_at = tweet.created_at
    post.data = tweet
    if !post.save
      post_exist = Post.find_last_by_provider_and_guid(self.provider, tweet.id)
      post.id = post_exist.id
      post.save
    end

    # to-do link & tag &mention
    if tweet.media? && tweet.media[0].class == Twitter::Media::Photo
      photo = Photo.new
      photo.post_id = post.id
      photo.remote_image_url = tweet.media[0].media_url.to_s
      photo.provider = self.provider
      photo.save
    end
    if tweet.hashtags?
      tweet.hashtags.each do |entity|
        author.tag( post, :with =>entity.text, :on => :author_post_tag )
      end
    end
    if tweet.user_mentions?
      tweet.user_mentions.each do |entity|
        author.tag( post, :with =>entity.screen_name, :on => :author_post_mention )
      end
    end

    event = Event.new
    event.post_id = post.id
    event.service_id = self.id
    event.user_id = self.user_id
    event.action = Event::UNREAD
    event.author_id = author.id
    event.favourite = 0
    event.created_at = tweet.created_at
    event.updated_at = tweet.created_at
    event.save

  end

  def get_home_timeline_items(since_id)
    if since_id.nil?
      options = {:count => 200, :include_rts => true}
    else
      options = {:count => 200, :include_rts => true, :since_id => since_id}
    end
    collect_with_max_id do |max_id|
      options[:max_id] = max_id unless max_id.nil?
      client.home_timeline(options)
    end
  end

  def profile_photo_url
    client.user(nickname).profile_image_url_https "original"
  end

  def delete_post post
    if post.present? && post.tweet_id.present?
      Rails.logger.debug "event=delete_from_service type=twitter sender_id=#{self.user_id}"
      delete_from_twitter post.tweet_id
    end
  end

  private

  def client
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Gitlab.config.services.twitter['key']
      config.consumer_secret     = Gitlab.config.services.twitter['secret']
      config.access_token        = self.access_token
      config.access_token_secret = self.access_secret
    end
  end

  def collect_with_max_id(collection=[], max_id=nil, &block)
    response = yield(max_id)
    collection += response
    response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
  end



  def attempt_post post, retry_count=0
    message = build_twitter_post post, retry_count
    client.update message
  rescue Twitter::Error::Forbidden => e
    if ! e.message.include? 'is over 140' || retry_count == 20
      raise e
    else
      attempt_post post, retry_count+1
    end
  end

  def build_twitter_post post, retry_count=0
    max_characters = MAX_CHARACTERS - retry_count

    post_text = post.message.plain_text_without_markdown
    truncate_and_add_post_link post, post_text, max_characters
  end

  def truncate_and_add_post_link post, post_text, max_characters
    return post_text unless needs_link? post, post_text, max_characters

    post_url = short_post_url(
      post,
      protocol: AppConfig.pod_uri.scheme,
      host: AppConfig.pod_uri.authority
    )

    truncated_text = post_text.truncate max_characters - SHORTENED_URL_LENGTH + 1
    truncated_text = restore_truncated_url truncated_text, post_text, max_characters

    "#{truncated_text} #{post_url}"
  end

  def needs_link? post, post_text, max_characters
    adjust_length_for_urls(post_text) > max_characters || post.photos.any?
  end

  def adjust_length_for_urls post_text
    real_length = post_text.length

    URI.extract(post_text, ['http','https']) do |url|
      # add or subtract from real length - urls for tweets are always
      # shortened to SHORTENED_URL_LENGTH
      if url.length >= SHORTENED_URL_LENGTH
        real_length -= url.length - SHORTENED_URL_LENGTH
      else
        real_length += SHORTENED_URL_LENGTH - url.length
      end
    end

    real_length
  end

  def restore_truncated_url truncated_text, post_text, max_characters
    return truncated_text if truncated_text !~ /#{LINK_PATTERN}\Z/

    url = post_text.match(LINK_PATTERN, truncated_text.rindex('http'))[0]
    truncated_text = post_text.truncate(
      max_characters - SHORTENED_URL_LENGTH + 2,
      separator: ' ', omission: ''
    )

    "#{truncated_text} #{url} ..."
  end

  def delete_from_twitter service_post_id
    client.status_destroy service_post_id
  end

  def hashtags

  end

  def mentions

  end
end
