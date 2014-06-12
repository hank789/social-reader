class FacebookService < Service
  include Rails.application.routes.url_helpers

  OVERRIDE_FIELDS_ON_FB_UPDATE = [:contact_id, :person_id, :request_id, :invitation_id, :photo_url, :name, :username]
  MAX_CHARACTERS = 63206

  def provider
    "facebook"
  end

  def post(tweet)
    author = Author.new
    author.provider = self.provider
    author.name = tweet['from']['name']
    author.guid = tweet['from']['id']
    author.slug = tweet['from']['category']
    author.remote_avatar_url = profile_photo_url(tweet['from']['id'])
    author.profile_url = "https://www.facebook.com/#{tweet['from']['id']}"

    if !author.save
      author_exist = Author.where(provider: self.provider, guid: tweet['from']['id']).first
      author.id = author_exist.id
      author.save
    end


    post = Post.new
    post.description = tweet['message']
    post.author_id = author.id
    post.guid = tweet['id']
    post.provider = self.provider
    post.link = "https://www.facebook.com/#{tweet['id'].gsub("_","/posts/")}"
    post.favourite_count = 0
    post.created_at = tweet['created_time']
    post.updated_at = tweet['updated_time']
    post.data = tweet
    if !post.save
      post_exist = Post.where(provider: self.provider, guid: tweet['id']).first
      post.id = post_exist.id
      post.save
    else
      # to-do link & tag &mention
      if tweet['type'] == 'photo'
        photo = Photo.new
        photo.post_id = post.id
        photo.remote_image_url = "https://graph.facebook.com/#{tweet['object_id']}/picture"
        photo.provider = self.provider
        photo.save
      end
    end

    event = Event.new
    event.post_id = post.id
    event.service_id = self.id
    event.user_id = self.user_id
    event.action = Event::UNREAD
    event.author_id = author.id
    event.created_at = tweet['created_time']
    event.updated_at = tweet['created_time']
    event.book_at = Time.now
    event.save

  end

  def get_home_timeline_items(since_id)
    @graph = Koala::Facebook::API.new(access_token)
    if since_id.nil?
      since_id = 1.year.ago.to_i
    end
    items = @graph.get_connections("me", "home", :since => since_id)
    next_items = items.next_page(:since => since_id)
    until next_items.nil? || next_items.empty? do
      items.concat(next_items)
      next_items = next_items.next_page(:since => since_id)
    end
    items
  end

  def profile_photo_url(uuid)
    "https://graph.facebook.com/#{uuid}/picture?type=large"
  end

end
