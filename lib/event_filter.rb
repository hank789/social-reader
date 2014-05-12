class EventFilter
  attr_accessor :params

  class << self
    def default_filter
      %w{ push posts merge_requests team}
    end

    def todo
      'todo'
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
  end

  def initialize params
    @params = if params
                params.dup
              else
                []#EventFilter.default_filter
              end
  end

  def apply_filter events
    return events unless params.present?

    filter = params.dup

    actions = []
    actions << Event::TODO if filter.include? 'todo'
    actions << Event::IMPORTANT if filter.include? 'important'
    actions << Event::NORMAL if filter.include? 'normal'
    actions << Event::LOW if filter.include? 'low'

    events = events.where(priority: actions)
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
