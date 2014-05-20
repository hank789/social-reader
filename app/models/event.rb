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
                  :post_id, :service_id, :action, :author_id, :favourite

  validates_uniqueness_of :post_id, :scope => :user_id

  UNREAD  = 10
  READ = 11

  belongs_to :user
  belongs_to :service
  belongs_to :post

  # Scopes
  scope :recent, -> { order("created_at DESC") }
  scope :load_events, ->(user_ids) { where(user_id: user_ids).recent }
  scope :load_star_events, ->(user_ids) { where(user_id: user_ids, favourite: 1).recent }

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

  def favorite
    return true if self.favourite == 1
    self.update_attribute(:favourite, 1)
    self.post.update_attribute(:favourite_count, self.post.favourite_count + 1)
  end
  def unfavorite
    return true if self.favourite == 0
    self.update_attribute(:favourite, 0)
    self.post.update_attribute(:favourite_count, self.post.favourite_count - 1)
  end
end
