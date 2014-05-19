class EventFilter
  attr_accessor :params

  class << self
    def default_filter
      %w{ important}
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

  def apply_filter events
    return events unless params.present?

    filter = params.dup

    actions = []
    actions << Event::IMPORTANT if filter.include? 'important'
    actions << Event::NORMAL if filter.include? 'normal'
    actions << Event::LOW if filter.include? 'low'

    if filter.include? 'favourite'
      if actions.present?
        events = events.where("priority in (?) OR favourite = ?", actions, 1)
      else
        events = events.where(favourite: 1)
      end
    else
      events = events.where(priority: actions)
    end
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
end
