# == Schema Information
#
# Table name: author
#
#  id                       :integer          not null, primary key
#  created_at               :datetime
#  updated_at               :datetime
#  name                     :string(255)
#  service_id              :string(255)      default("")
#  guid              :string(255)      default("")
#  data              :string(255)      default("")
#

class Author < ActiveRecord::Base
  attr_accessible :name, :provider, :guid, :avatar, :description, :profile_url
  validates_uniqueness_of :guid, :scope => :provider

  has_many :posts, foreign_key: :author_id
end
