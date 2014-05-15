module EventsHelper
  def link_to_author(event)
    author = event.post.author
    link_to author.name, author.profile_url
  end

  def event_action_name(event)
    #target = 'project'

    #[event.action_name, target].join(" ")
    event.service.provider
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

  def event_title(event)
    case event.post.provider
    when "twitter"
      twitter_title(event.post.data)
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
      EventFilter.todo     => "icon-upload-alt",
      EventFilter.important   => "icon-check",
      EventFilter.normal => "icon-comments",
      EventFilter.low     => "icon-user",
    }
  end

  def event_note(text)
    text = first_line(text)
    text = truncate(text, length: 150)
    sanitize(markdown(text), tags: %w(a img b pre p))
  end

  def event_commit_title(message)
    escape_once(truncate(message.split("\n").first, length: 70))
  rescue
    "--broken encoding"
  end
end
