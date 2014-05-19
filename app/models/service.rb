# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  service_type        :string(255)
#  title       :string(255)
#  token       :string(255)
#  project_id  :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  active      :boolean          default(FALSE), not null
#  project_url :string(255)
#  subdomain   :string(255)
#  room        :string(255)
#  recipients  :text
#  api_key     :string(255)
#

# To add new service you should build a class inherited from Service
# and implement a set of methods
class Service < ActiveRecord::Base
  attr_accessible :provider, :info, :nickname, :uid, :access_token, :access_secret, :priority, :active,
                  :visibility_level, :service_name, :since_id, :last_activity_at, :last_unread_count, :last_read_time
  self.inheritance_column = :service_name
  belongs_to :user
  has_many :events
  validates_uniqueness_of :uid, :scope => :service_name
  # For Hash only
  serialize :info
  default_scope { where(active: 1) }

  def profile_photo_url
    nil
  end

  def delete_post(post)
    #don't do anything (should be overriden by service extensions)
  end

  class << self

    def titles(service_strings)
      service_strings.map {|s| "#{s.titleize}Service"}
    end

    def first_from_omniauth( auth_hash )
      @@auth = auth_hash
      where( type: service_type, uid: options[:uid] ).first
    end

    def initialize_from_omniauth( auth_hash )
      @@auth = auth_hash
      service_type.constantize.new( options )
    end

    def auth
      @@auth
    end

    def service_type
      "#{options[:provider].camelize}Service"
    end

    def options
      {
          nickname:      auth['info']['nickname'],
          access_token:  auth['credentials']['token'],
          access_secret: auth['credentials']['secret'],
          uid:           auth['uid'],
          provider:      auth['provider'],
          info:          auth['info'],
          service_name: "#{auth['provider'].camelize}Service",
          priority:     Event::IMPORTANT,
          active:       1,
          visibility_level:       Gitlab::VisibilityLevel::PRIVATE
      }
    end

    def visibility_levels
      Gitlab::VisibilityLevel.options
    end

    private :auth, :service_type, :options
  end
end
