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
  attr_accessible :project, :action, :user_id, :priority,
                  :post_id, :service_id, :action

  default_scope { where.not(user_id: nil) }
  validates_uniqueness_of :post_id, :scope => [:user_id, :priority]

  TODO      = 1
  IMPORTANT = 2
  NORMAL    = 3
  LOW       = 4

  UNREAD  = 10
  READ = 11

  belongs_to :user
  belongs_to :service
  belongs_to :post

  # Scopes
  scope :recent, -> { order("created_at DESC") }
  scope :priority_todo, -> { where(priority: TODO) }

  class << self

  end

  def priority_options
    {
        'To-Do'  => TODO,
        'Important' => IMPORTANT,
        'Normal'   => NORMAL,
        'Low' => LOW
    }
  end

  def proper?
    if todo? || important? || normal? || low?
      true
    end
  end

  def target_title
    if self.target_type && self.target_id

      target.title
    end
  end

  def todo?
    priority == self.class::TODO
  end

  def important?
    priority == self.class::IMPORTANT
  end

  def normal?
    priority == self.class::NORMAL
  end

  def low?
    priority == self.class::LOW
  end

  def milestone?
    target_type == "Milestone"
  end

  def note?
    target_type == "Note"
  end

  def issue?
    target_type == "Post"
  end

  def merge_request?
    target_type == "MergeRequest"
  end

  def joined?
    action == JOINED
  end

  def left?
    action == LEFT
  end

  def membership_changed?
    joined? || left?
  end

  def issue
    target if target_type == "Post"
  end

  def merge_request
    target if target_type == "MergeRequest"
  end

  def action_name
    "opened"
  end

  def body?
    true
  end
end
