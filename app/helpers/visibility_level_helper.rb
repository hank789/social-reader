module VisibilityLevelHelper
  def visibility_level_color(level)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      'cgreen'
    when Gitlab::VisibilityLevel::PUBLIC
      'cblue'
    end
  end

  def visibility_level_description(level)
    capture_haml do
      haml_tag :span do
        case level
        when Gitlab::VisibilityLevel::PRIVATE
          haml_concat "Private content is only visible with your account, do not appear in any open space."
        when Gitlab::VisibilityLevel::PUBLIC
          haml_concat "Public content can be visible to anyone, and will appear in your homepage."
        end
      end
    end
  end

  def visibility_level_icon(level)
    case level
    when Gitlab::VisibilityLevel::PRIVATE
      private_icon
    when Gitlab::VisibilityLevel::PUBLIC
      public_icon
    end
  end

  def visibility_level_label(level)
    Service.visibility_levels.key(level)
  end

  def restricted_visibility_levels
    current_user.is_admin? ? [] : gitlab_config.restricted_visibility_levels
  end
end
