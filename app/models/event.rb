# == Schema Information
#
# Table name: events
#
#  id          :integer          not null, primary key
#  target_type :string(255)
#  target_id   :integer
#  project_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  priority      :integer
#  user_id   :integer
#

class Event < ActiveRecord::Base
  attr_accessible :project, :action, :user_id,
                  :post_id, :service_id, :action, :author_id, :stars_at, :read_at, :book_at, :archive_at

  validates_uniqueness_of :post_id, :scope => :user_id

  UNREAD  = 10
  READ = 11
  ARCHIVE = 12

  belongs_to :user
  belongs_to :service
  belongs_to :post

  # Scopes
  scope :recent, -> { order("created_at DESC") }
  scope :load_events, ->(user_ids) { where(user_id: user_ids, action: Event::UNREAD).recent }
  scope :load_archive_events, ->(user_ids) { where(user_id: user_ids).where("action >= ?", 11).recent }
  scope :load_star_events, ->(user_ids) { where(user_id: user_ids).where.not(stars_at: nil) }
  scope :load_events_for_service, ->(services_ids) { where(service_id: services_ids).recent }

  def read?
    action == READ
  end

  def unread?
    action == UNREAD
  end


  def action_name
    "opened"
  end

  def body?
    true
  end

  def favorite(uid)
    if self.user_id != uid
      c_event = Event.where(user_id: uid, post_id: self.post.id).first
      if c_event
        return true if c_event.stars_at
        c_event.stars_at = Time.now
        c_event.save
        self.post.update_attributes(favourite_count: self.post.favourite_count + 1)
      else
        c_event = Event.new
        c_event.post_id = self.post.id
        c_event.service_id = self.service.id
        c_event.user_id = uid
        c_event.action = Event::READ
        c_event.author_id = self.author_id
        c_event.created_at = self.post.created_at
        c_event.updated_at = self.post.created_at
        c_event.stars_at = Time.now
        c_event.read_at = Time.now
        c_event.save
        self.post.update_attributes(favourite_count: self.post.favourite_count + 1)
      end
      return true
    end

    return true if self.stars_at
    self.update_attributes(stars_at: Time.now, action: Event::READ, read_at: Time.now)
    self.post.update_attributes(favourite_count: self.post.favourite_count + 1)
  end
  def unfavorite(uid)
    if self.user_id != uid
      c_event = Event.where(user_id: uid, post_id: self.post.id).first
      if c_event
        if c_event.stars_at.nil?
          c_event.destroy
          return true
        end
        c_event.destroy
        self.post.update_attributes(favourite_count: self.post.favourite_count - 1)
      end
      return true
    end

    return true if self.stars_at.nil?
    self.update_attributes(stars_at: nil)
    self.post.update_attributes(favourite_count: self.post.favourite_count - 1)
  end

  class << self
    # Cached in redis
    def expire_cache
      Rails.cache.delete(cache_key(:graph_log))
    end

    def graph_log(uid)
      Rails.cache.fetch(cache_key(:graph_log)) do
        from_date = 14.days.ago.strftime("%Y-%m-%d").to_time
        to_date = Time.now.strftime("%Y-%m-%d").to_time
        date_diff = 14
        log_info = []
        while date_diff >=0
          from_next = from_date + 86400
          book_count = Event.where(user_id: uid, book_at: from_date..from_next).count
          read_count = Event.where(user_id: uid, read_at: from_date..from_next).count
          star_count = Event.where(user_id: uid, stars_at: from_date..from_next).count
          log_info.push({:period => from_date.strftime("%Y-%m-%d"),:book => book_count, :read => read_count, :star => star_count})
          date_diff -= 1
          from_date = from_next
        end
        return log_info
      end
    end

    def cache_key(type)
      "#{type}"
    end
  end

end
