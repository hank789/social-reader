class InstagramService < Service
  include Rails.application.routes.url_helpers

  def provider
    "instagram"
  end

  def post(tweet)
    tweet.created_time = Time.at(tweet.created_time.to_i)
    author = Author.where(guid: tweet.user.id, provider: self.provider).first_or_initialize

    author.name = tweet.user.full_name
    author.slug = tweet.user.username
    author.remote_avatar_url = tweet.user.profile_picture
    author.profile_url = "http://instagram.com/#{tweet.user.username}"
    author.save

    post = Post.where(guid: tweet.id, provider: self.provider).first_or_initialize
    post_new = post.new_record?
    post.description = tweet.caption.text unless tweet.caption.nil?
    post.author_id = author.id
    post.link = tweet.link
    post.favourite_count = 0
    post.created_at = tweet.created_time
    post.updated_at = tweet.created_time
    post.data = tweet
    post.save

    if post_new
      # to-do link & tag &mention
      photo = Photo.new
      photo.post_id = post.id
      photo.remote_image_url = tweet.images.standard_resolution.url
      photo.provider = self.provider
      photo.save
    end

    event = Event.new
    event.post_id = post.id
    event.service_id = self.id
    event.user_id = self.user_id
    event.action = Event::UNREAD
    event.author_id = author.id
    event.created_at = tweet.created_time
    event.updated_at = tweet.created_time
    event.book_at = Time.now
    event.save
  end

  def get_home_timeline_items(since_id)
    client = Instagram.client(:access_token => access_token)
    if since_id.nil?
      page_1 = client.user_media_feed
    else
      since_id = since_id.split('_')
      page_1 = client.user_media_feed(:min_id => since_id[0].to_i)
    end
    if page_1.empty?
      page_1 = client.user_media_feed
    end
    page_2_max_id = page_1.pagination.next_max_id
    until page_2_max_id.nil? do
      page_2_max_id = page_2_max_id.split('_')
      page_2 = client.user_media_feed(:max_id => page_2_max_id[0].to_i )
      page_1.concat(page_2)
      page_2_max_id = page_2.pagination.next_max_id
    end
    page_1
  end

end
