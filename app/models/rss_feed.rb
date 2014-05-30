# == Schema Information
#
# Table name: rss_feeds
#
#

class RssFeed < ActiveRecord::Base

  attr_accessible :name, :url, :last_fetched, :status, :last_fetched_id

  validates_uniqueness_of :name
  validates_uniqueness_of :url

  has_many :rss_feeds_rss_categories, dependent: :destroy
  has_many :rss_categories, through: :rss_feeds_rss_categories

  STATUS = { green: 0, yellow: 1, red: 2, block: 3 }
  MIN_YEAR = 1970

  def self.list
    RssFeed.all
  end

  def self.fetch(id)
    RssFeed.find(id)
  end

  def self.fetch_by_ids(ids)
    RssFeed.where(id: ids)
  end

  def self.update_last_fetched(feed, timestamp)
    if self.valid_timestamp?(timestamp, feed.last_fetched)
      feed.last_fetched = timestamp
      feed.status = :green
      feed.save
    end
  end

  def self.delete(feed_id)
    RssFeed.destroy(feed_id)
  end

  def self.set_status(status, feed)
    feed.status = status
    feed.save
  end

  def status
    STATUS.key(read_attribute(:status))
  end

  def status=(s)
    write_attribute(:status, STATUS[s])
  end

  def status_bubble
    return :yellow if status == :red && stories.any?
    status
  end

  def unread_stories
    stories.where('is_read = ?', false)
  end

  def has_unread_stories
    unread_stories.any?
  end

  def post_count
    Post.where(provider: id).count
  end

  def user_count
    Service.where(access_token: id).count
  end

  private

  def self.valid_timestamp?(new_timestamp, current_timestamp)
    new_timestamp && new_timestamp.year >= MIN_YEAR &&
        (current_timestamp.nil? || new_timestamp > current_timestamp)
  end

end
