# Gitlab::VisibilityLevel module
#
# Define allowed public modes that can be used for
# GitLab projects to determine project public mode
#
module Gitlab
  module VisibilityLevel
    PRIVATE  = 0
    PUBLIC   = 20

    class << self
      def values
        options.values
      end

      def options
        {
          'Private'  => PRIVATE,
          'Public'   => PUBLIC
        }
      end
      
      def allowed_for?(user, level)
        user.is_admin? || !Gitlab.config.gitlab.restricted_visibility_levels.include?(level)
      end
    end

    def private?
      visibility_level_field == PRIVATE
    end

    def public?
      visibility_level_field == PUBLIC
    end
  end
end
