module API
  module Entities
    class User < Grape::Entity
      expose :id, :username, :email, :name, :bio, :skype, :linkedin, :twitter, :website_url,
             :theme_id, :color_scheme_id, :state, :created_at, :extern_uid, :provider, :avatar
      expose :is_admin?, as: :is_admin
      expose :can_create_group?, as: :can_create_group
      expose :can_create_project?, as: :can_create_project

      expose :avatar_url do |user, options|
        if user.avatar.present?
          user.avatar.url
        end
      end
    end

    class UserSafe < Grape::Entity
      expose :name, :username
    end

    class UserBasic < Grape::Entity
      expose :id, :username, :email, :name, :state, :created_at, :avatar
    end

    class UserLogin < User
      expose :private_token
    end

    class Note < Grape::Entity
      expose :id
      expose :note, as: :body
      expose :attachment_identifier, as: :attachment
      expose :user, using: Entities::UserBasic
      expose :created_at
    end


    class Label < Grape::Entity
      expose :name
    end
  end
end
