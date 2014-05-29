# == Schema Information
#
# Table name: rss_feeds
#
#

class RssFeedsRssCategory < ActiveRecord::Base

  attr_accessible :rss_feed_id, :rss_category_id

  belongs_to :rss_feed
  belongs_to :rss_category

  validates :rss_feed_id, presence: true
  validates :rss_category_id, presence: true
  validates :rss_feed_id, uniqueness: { scope: [:rss_category_id], message: "already exists in group" }

  scope :get_rss_feeds_by_cid, ->(cid) { where(rss_category_id: cid) }

  def self.list
    RssFeedsRssCategory.order('rss_category_id DESC')
  end

end
