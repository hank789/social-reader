module PriorityLevelHelper
  def priority_level_color(level)
    case level
      when Event::IMPORTANT
      'cgreen'
      when Event::NORMAL
      'cblue'
      when Event::LOW
      'cblue'
    end
  end

  def priority_level_description(level)
    capture_haml do
      haml_tag :span do
        case level
        when Event::IMPORTANT
          haml_concat "Important"
        when Event::NORMAL
          haml_concat "Normal"
        when Event::LOW
          haml_concat "Low"
        end
      end
    end
  end

  def priority_level_icon(level)
    case level
    when Event::IMPORTANT
      content_tag :i, nil, class: 'icon-fire'
    when Event::NORMAL
      content_tag :i, nil, class: 'icon-coffee'
    when Event::LOW
      content_tag :i, nil, class: 'icon-beer'
    end
  end

  def priority_level_label(level)
    Event.priority_options.key(level)
  end

end
