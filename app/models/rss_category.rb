# == Schema Information
#
# Table name: rss_categories
#
#

class RssCategory < ActiveRecord::Base

  attr_accessible :name, :description, :status, :parent_id, :select_type

  has_many :rss_feeds_rss_categories, dependent: :destroy
  has_many :rss_feeds, through: :rss_feeds_rss_categories

  scope :parent_category, ->() { where(parent_id: -1) }
  scope :child_category, ->(pid) { where(parent_id: pid) }

  def self.list
    RssCategory.where(status: 1)
  end

end
