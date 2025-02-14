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
  attr_accessible :provider, :info, :nickname, :uid, :access_token, :access_secret, :active,
                  :service_name, :since_id, :last_activity_at, :last_unread_count, :last_read_time
  self.inheritance_column = :service_name
  belongs_to :user
  has_many :events
  validates :access_token, presence: true
  validates_uniqueness_of :uid, :scope => :service_name
  # For Hash only
  serialize :info
  default_scope { where(active: 1) }
  scope :is_active, -> { where(active: 1) }
  scope :inactive, -> { where(active: 0) }
  scope :rss_type, -> { where(service_name: "RssFeedService") }
  scope :social_type, -> { where.not(service_name: "RssFeedService") }
  scope :all_with_inactive, -> { where(active: [0,1]) }
  scope :by_user, -> { order('user_id ASC') }

  IMPORTANT = 1
  NORMAL    = 2
  LOW       = 3

  def profile_photo_url
    nil
  end

  def delete_post(post)
    #don't do anything (should be overriden by service extensions)
  end

  class << self
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
          active:       1,
          last_unread_count:  0,
          last_read_time: Time.now,
          last_activity_at: Time.now
      }
    end

    def filter filter_name
      case filter_name
        when "active"; self.is_active
        when "inactive"; self.inactive
        when "rss"; self.rss_type
        when "social"; self.social_type
        else
          self.is_active
      end
    end

    private :auth, :service_type, :options
  end

  def active?
    active
  end

  def post_count
    Event.where(service_id: id, user_id: user_id).count
  end
end
