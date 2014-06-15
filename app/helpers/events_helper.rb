module EventsHelper
  def link_to_author(event)
    author = event.post.author
    link_to author.name, author.profile_url, :target => "_blank"
  end

  def author_avatar(event)
    case event.service.service_name
      when 'RssFeedService'
        return image_tag "https://plus.google.com/_/favicon?domain=#{event.post.author.profile_url.split('/')[2]}", class: "avatar s32", alt:''
      else
        return image_tag event.post.author.avatar, class: "avatar s32", alt:''
    end
  end

  def event_action_name(event)
    case event.service.service_name
      when 'RssFeedService'
        return raw "via <a href='#{event.post.author.profile_url}' target='_blank'>#{event.post.author.name}</a>"
      when 'InstagramService'
        return raw "via <a href='#{event.post.link}' target='_blank'>#{event.service.provider}</a> base <a href='http://instagram.com/#{event.service.info.nickname}' target='_blank'>#{event.service.info.name}</a>"
      else
        return raw "via <a href='#{event.post.link}' target='_blank'>#{event.service.provider}</a> base <a href='#{event.service.info.urls[event.service.provider.capitalize!]}' target='_blank'>#{event.service.info.name}</a>"
    end
  end

  def event_filter_link key, tooltip
    key = key.to_s
    inactive = if @event_filter.active? key
                 nil
               else
                 'inactive'
               end

    content_tag :div, class: "filter_icon #{inactive}" do
      link_to request.path, class: 'has_tooltip event_filter_link', id: "#{key}_event_filter", 'data-original-title' => tooltip do
        content_tag :i, nil, class: icon_for_event[key]
      end
    end
  end

  def event_star_filter_link key, tooltip
    key = key.to_s
    inactive = if @event_filter.active? key
                 nil
               else
                 'inactive'
               end

    content_tag :div, class: "filter_icon #{inactive}" do
      link_to request.path, class: 'has_tooltip event_star_filter_link', id: "#{key}_event_filter", 'data-original-title' => tooltip do
        content_tag :i, nil, class: icon_for_event[key]
      end
    end
  end

  def event_title(event)
    case event.post.provider
      when "twitter"
        twitter_title(event.post.data)
      else
        event.post.description
    end
  end

  def twitter_title(tweet)
    entities = {}
    if tweet.user_mentions?
      tweet.user_mentions.each do |entity|
        entities["start_#{entity.indices[0].to_s.rjust(5,'0')}"] = {:find=>entity.screen_name,:replace=>"<a target='_blank' href='http://twitter.com/#{entity.screen_name}'>@#{entity.screen_name}</a>",:start=>entity.indices[0],:end=>entity.indices[1]}
      end
    end
    if tweet.hashtags?
      tweet.hashtags.each do |entity|
        entities["start_#{entity.indices[0].to_s.rjust(5,'0')}"] = {:find=>entity.text,:replace=>twitter_hashtag_link(entity.text),:start=>entity.indices[0],:end=>entity.indices[1]}
      end
    end
    if tweet.uris?
      tweet.uris.each do |entity|
        entities["start_#{entity.indices[0].to_s.rjust(5,'0')}"] = {:find=>entity.url.to_s,:replace=>"<a target='_blank' href='#{entity.expanded_url.to_s}'>#{entity.display_url.to_s}</a>",:start=>entity.indices[0],:end=>entity.indices[1]}
      end
    end
    entities = entities.sort
    str = tweet.full_text
    diff = 0
    entities.each do |entity|
      start_num = entity[1][:start] + diff
      end_num = entity[1][:end] + diff
      str = substr_replace(str,entity[1][:replace], start_num, end_num - start_num)
      diff += entity[1][:replace].length - (end_num - start_num)
    end
    str
  end

  def substr_replace(str,replacement,start,length=nil)
    string_length =  str.length
    if start < 0
      start = [0, string_length + start].max
    elsif start > string_length
      start = string_length
    end
    if length < 0
      length = [0,string_length - start + length].max
    elsif length.nil? || length > string_length
      length = string_length
    end
    if start + length > string_length
      length = string_length - start
    end
    str[0,start] + replacement + str[start+length,string_length-start-length]
  end

  def twitter_hashtag_link(hashtag)
    if hashtag[0] != "#"
      hashtag = "#" + hashtag
    end
    "<a target='_blank' href='http://twitter.com/search?q=#{hashtag}'>#{hashtag}</a>"
  end

  def icon_for_event
    {
      EventFilter.important     => "icon-fire",
      EventFilter.normal => "icon-coffee",
      EventFilter.low     => "icon-beer",
      EventFilter.favourite     => "icon-star",
      EventStarFilter.posttime     => "icon-rss",
      EventStarFilter.startime     => "icon-star",
    }
  end

  def event_note(event)
    #text = first_line(text)
    text = event.post.description
    text.gsub! '<br>', ''
    t_length = text.length
    if t_length >= 251
      short_text = truncate_html(text, length: 250, omission: '<a class="text-expander js-toggle-button">...</a>')
      short_text2 = short_text.clone
      short_text2.gsub! '<a class="text-expander js-toggle-button">...</a></p>', ''
      long_text = truncate_html(text, length: t_length + 100 , omission: '')
      long_text.gsub! short_text2, ''
      return  "#{short_text}<div class='js-toggle-content'>#{long_text}</div>".html_safe
    else
      return text.html_safe
    end
  end

  def link_to_rss(event)
    raw "<a href='#{event.post.link}' target='_blank'>#{event.post.title}</a>"
  end

  def favorite_tag(event)
    return "" if current_user.blank?
    icon = content_tag(:i, "", :class => "icon-star-empty")
    link_title = "star"
    if current_user.id != event.user_id
      c_event = Event.where(user_id: current_user.id, post_id: event.post.id).first
    else
      c_event = nil
    end
    if (event.stars_at && current_user.id == event.user_id) || (c_event && c_event.stars_at)
      icon = content_tag(:i, "", :class => "icon-star")
      link_title = "unstar"
    end
    favorite_label = raw "#{icon}"
    raw "#{link_to(favorite_label, "#", :onclick => "return Events.favorite(this);", 'data-id' => event.id, :title => link_title, :rel => "twipsy")}"
  end

  def share_to_chat(event)

  end
end
