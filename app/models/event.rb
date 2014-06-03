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
                  :post_id, :service_id, :action, :author_id, :stars_at

  validates_uniqueness_of :post_id, :scope => :user_id

  UNREAD  = 10
  READ = 11

  belongs_to :user
  belongs_to :service
  belongs_to :post

  # Scopes
  scope :recent, -> { order("created_at DESC") }
  scope :load_events, ->(user_ids) { where(user_id: user_ids, action: Event::UNREAD).recent }
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
        self.post.update_attribute(:favourite_count, self.post.favourite_count + 1)
      else
        c_event = Event.new
        c_event.post_id = self.post.id
        c_event.service_id = self.service.id
        c_event.user_id = uid
        c_event.action = Event::UNREAD
        c_event.author_id = self.author_id
        c_event.created_at = self.post.created_at
        c_event.updated_at = self.post.created_at
        c_event.stars_at = Time.now
        c_event.save
        self.post.update_attribute(:favourite_count, self.post.favourite_count + 1)
      end
      return true
    end

    return true if self.stars_at
    self.update_attribute(:stars_at, Time.now)
    self.post.update_attribute(:favourite_count, self.post.favourite_count + 1)
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
        self.post.update_attribute(:favourite_count, self.post.favourite_count - 1)
      end
      return true
    end

    return true if self.stars_at.nil?
    self.update_attribute(:stars_at, nil)
    self.post.update_attribute(:favourite_count, self.post.favourite_count - 1)
  end
end
