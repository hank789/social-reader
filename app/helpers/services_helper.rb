module ServicesHelper
  def connected_info(service)
    case service.provider
      when 'instagram'
        return raw "#{service.provider.capitalize!} <small class='light'>connected to <a href='http://instagram.com/#{service.info.nickname}' target='_blank'>#{service.info.name}</a></small>"
      else
        return raw "#{service.provider.capitalize!} <small class='light'>connected to <a href='#{service.info.urls[service.provider.capitalize!]}' target='_blank'>#{service.info.name}</a></small>"
    end
  end

  def connected_title(service)
    case service.provider
      when 'instagram'
        return raw "<a href='http://instagram.com/#{service.info.nickname}' target='_blank'>#{service.info.name}</a>"
      else
        return raw "<a href='#{service.info.urls[service.provider.capitalize!]}' target='_blank'>#{service.info.name}</a>"
    end
  end
end
