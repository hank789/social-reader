# coding: utf-8
class Photo < ActiveRecord::Base

  attr_accessible :post_id, :image, :provider

  belongs_to :post
  validates_uniqueness_of :post_id, :scope => :image

  mount_uploader :image, AttachmentUploader

end