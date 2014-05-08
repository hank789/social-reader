# == Schema Information
#
# Table name: projects
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  slug                   :string(255)
#  description            :text
#  created_at             :datetime
#  updated_at             :datetime
#  creator_id             :integer
#

class Project < ActiveRecord::Base
  extend Enumerize

  ActsAsTaggableOn.strict_case_match = true

  attr_accessible :name, :slug, :description, :creator_id

  # Relations
  belongs_to :creator,      foreign_key: "creator_id", class_name: "User"

end
