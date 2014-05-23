module ServicesHelper
  def connected_info(service)
    raw "#{service.provider.capitalize!} <small class='light'>connected to <a href='#{service.info.urls[service.provider.capitalize!]}' target='_blank'>#{service.info.name}</a></small>"
  end

  def connected_title(service)
    raw "<a href='#{service.info.urls[service.provider.capitalize!]}' target='_blank'>#{service.info.name}</a>"
  end
end
