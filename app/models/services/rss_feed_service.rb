class RssFeedService < Service
  include Rails.application.routes.url_helpers

  def post(post)
    event = Event.new
    event.post_id = post.id
    event.service_id = self.id
    event.user_id = self.user_id
    event.action = Event::UNREAD
    event.author_id = post.author_id
    event.created_at = post.created_at
    event.updated_at = post.created_at
    event.save
  end

  def get_home_timeline_items(since_id)
    if since_id.nil?
      posts = Post.where(provider: self.access_token)
    else
      posts = Post.where(provider: self.access_token).where("created_at > ?", since_id)
    end
    posts
  end

end
