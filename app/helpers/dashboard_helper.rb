module DashboardHelper
  def filter_path(entity, options={})
    exist_opts = {
      state: params[:state],
      scope: params[:scope],
      project_id: params[:project_id],
    }

    options = exist_opts.merge(options)

    path = request.path
    path << "?#{options.to_param}"
    path
  end

  def entities_per_project(project, entity)
    case entity.to_sym
    when :issue then @issues.where(project_id: project.id)
    when :merge_request then @merge_requests.where(target_project_id: project.id)
    else
      []
    end.count
  end

  def projects_dashboard_filter_path(options={})
    exist_opts = {
      sort: params[:sort],
      scope: params[:scope],
      group: params[:group],
    }

    options = exist_opts.merge(options)

    path = request.path
    path << "?#{options.to_param}"
    path
  end

  def service_name(service)
    case service.service_name
      when 'RssFeedService'
        feed = RssFeed.find(service.access_token)
        return feed.name
      else
        return service.provider
    end
  end

  def service_avatar(service)
    case service.service_name
      when 'RssFeedService'
        author = Author.where(provider: service.access_token).first
        return author.avatar unless author.nil?
      else
        return image_path("services/#{service.provider}.png")
    end
  end
end
