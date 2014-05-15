# coding: utf-8
class Photo < ActiveRecord::Base

  attr_accessible :post_id, :image, :provider

  belongs_to :post

  mount_uploader :image, AttachmentUploader

end