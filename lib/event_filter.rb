class EventFilter
  attr_accessor :params

  class << self
    def default_filter
      %w{ important normal}
    end

    def important
      'important'
    end

    def normal
      'normal'
    end

    def low
      'low'
    end
    def favourite
      'favourite'
    end
  end

  def initialize params
    @params = if params
                params.dup
              else
                EventFilter.default_filter
              end
  end

  def show_filter
    return events unless params.present?

    filter = params.dup

    actions = ''
    actions += 'important ' if filter.include? 'important'
    actions += 'normal ' if filter.include? 'normal'
    actions += 'low ' if filter.include? 'low'
    actions += 'favourite ' if filter.include? 'favourite'
    actions
  end

  def apply_filter events,uid
    return events unless params.present?

    filter = params.dup

    actions = []
    actions << Service::IMPORTANT if filter.include? 'important'
    actions << Service::NORMAL if filter.include? 'normal'
    actions << Service::LOW if filter.include? 'low'

    if actions.empty?
      services_ids = filter[0].to_i
    else
      services_ids = Service.where(priority: actions, user_id: uid).pluck(:id)
    end
    events = events.where(service_id: services_ids)
  end

  def options key
    filter = params.dup

    if filter.include? key
      filter.delete key
    else
      filter << key
    end

    filter
  end

  def active? key
    params.include? key
  end

  def include_key? key
    return true unless params.present?
    filter = params.dup
    actions = []
    actions << Service::IMPORTANT if filter.include? 'important'
    actions << Service::NORMAL if filter.include? 'normal'
    actions << Service::LOW if filter.include? 'low'
    actions.include? key
  end
end
