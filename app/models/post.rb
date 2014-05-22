# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  assignee_id  :integer
#  author_id    :integer
#  project_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  position     :integer          default(0)
#  branch_name  :string(255)
#  description  :text
#  milestone_id :integer
#  state        :string(255)
#  iid          :integer
#

class Post < ActiveRecord::Base

  belongs_to :author
  acts_as_taggable_on :author_post_tag
  acts_as_taggable_on :author_post_mention
  # For Hash only
  serialize :data
  validates :author, presence: true
  validates_uniqueness_of :guid, :scope => :provider

  default_value_for :title, ''

  scope :authored, ->(user) { where(author_id: user) }
  scope :recent, -> { order("created_at DESC") }

  ActsAsTaggableOn.strict_case_match = true

  has_many :events
  has_many :photos
  belongs_to :author

  attr_accessible :title, :author_id, :position, :description, :guid, :provider, :data, :favourite_count,
                  :label_list

  acts_as_taggable_on :labels

  class << self
    def search query
      where("posts.title LIKE :query OR posts.description LIKE :query", query: "%#{query}%")
    end

    def search_by_description query
      where("LOWER(posts.description) LIKE :query", query: "%#{query.downcase}%")
    end

    def publicish(user)
      joins('LEFT JOIN events ON posts.id = events.post_id').where('events.user_id = ?', user.id)
    end
  end
  # Reset issue events cache
  #
  # Since we do cache @event we need to reset cache in special cases:
  # * when an issue is updated
  # Events cache stored like  events/23-20130109142513.
  # The cache key includes updated_at timestamp.
  # Thus it will automatically generate a new fragment
  # when the event is updated because the key changes.
  def reset_events_cache
    Event.where(target_id: self.id, target_type: 'Post').
      order('id DESC').limit(100).
      update_all(updated_at: Time.now)
  end
end
