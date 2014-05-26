class InstagramService < Service
  include Rails.application.routes.url_helpers

  def provider
    "instagram"
  end

  def post(tweet)
    tweet.created_time = Time.at(tweet.created_time.to_i)
    author = Author.new
    author.provider = self.provider
    author.name = tweet.user.full_name
    author.guid = tweet.user.id
    author.slug = tweet.user.username
    author.remote_avatar_url = tweet.user.profile_picture
    author.profile_url = "http://instagram.com/#{tweet.user.username}"

    if !author.save
      author_exist = Author.find_last_by_provider_and_guid(self.provider,tweet.user.id)
      author.id = author_exist.id
      author.save
    end


    post = Post.new
    post.description = tweet.caption.text unless tweet.caption.nil?
    post.author_id = author.id
    post.guid = tweet.id
    post.provider = self.provider
    post.link = tweet.link
    post.favourite_count = 0
    post.created_at = tweet.created_time
    post.updated_at = tweet.created_time
    post.data = tweet
    if !post.save
      post_exist = Post.find_last_by_provider_and_guid(self.provider, tweet.id)
      post.id = post_exist.id
      post.save
    else
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
    event.save
  end

  def get_home_timeline_items(since_id)
    client = Instagram.client(:access_token => access_token)
    if since_id.nil?
      options = {:count => 100}
    else
      options = {:count => 100, :min_id => since_id}
    end
    page_1 = client.user_media_feed(options)
    page_2_max_id = page_1.pagination.next_max_id
    until page_2_max_id.nil? do
      page_2 = client.user_media_feed(:count => 100, :max_id => page_2_max_id )
      page_1.concat(page_2)
      page_2_max_id = page_2.pagination.next_max_id
    end
    page_1
  end

end
