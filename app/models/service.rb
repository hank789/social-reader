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
  attr_accessible :provider, :info, :nickname, :uid, :access_token, :access_secret, :users_project_id, :active, :access

  belongs_to :user
  validates_uniqueness_of :uid, :scope => :type

  def profile_photo_url
    nil
  end

  def delete_post(post)
    #don't do anything (should be overriden by service extensions)
  end

  class << self

    def titles(service_strings)
      service_strings.map {|s| "Services::#{s.titleize}"}
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
      "Services::#{options[:provider].camelize}"
    end

    def options
      {
          nickname:      auth['info']['nickname'],
          access_token:  auth['credentials']['token'],
          access_secret: auth['credentials']['secret'],
          uid:           auth['uid'],
          provider:      auth['provider'],
          info:          auth['info'],
          users_project_id: 1,
          active:       1,
          access:       1
      }
    end

    private :auth, :service_type, :options
  end
end
