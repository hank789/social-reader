module PriorityLevelHelper
  def priority_level_color(level)
    case level
      when Service::IMPORTANT
      'cgreen'
      when Service::NORMAL
      'cblue'
      when Service::LOW
      'cblue'
    end
  end

  def priority_level_description(level)
    capture_haml do
      haml_tag :span do
        case level
        when Service::IMPORTANT
          haml_concat "Important"
        when Service::NORMAL
          haml_concat "Normal"
        when Service::LOW
          haml_concat "Low"
        end
      end
    end
  end

  def priority_level_icon(level)
    case level
    when Service::IMPORTANT
      content_tag :i, nil, class: 'icon-fire'
    when Service::NORMAL
      content_tag :i, nil, class: 'icon-coffee'
    when Service::LOW
      content_tag :i, nil, class: 'icon-beer'
    end
  end

  def priority_level_label(level)
    Service.priority_options.key(level)
  end

end
