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
  # For Hash only
  serialize :data
  validates :author, presence: true
  validates :title, presence: true, length: { within: 0..255 }
  validates_uniqueness_of :guid, :scope => :provider

  scope :authored, ->(user) { where(author_id: user) }
  scope :recent, -> { order("created_at DESC") }

  ActsAsTaggableOn.strict_case_match = true

  has_many :events
  has_many :photos
  belongs_to :author

  attr_accessible :title, :author_id, :position, :description, :guid, :provider, :data,
                  :label_list

  acts_as_taggable_on :labels

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
