class EventStarFilter
  attr_accessor :params

  class << self
    def default_filter
      %w{ posttime}
    end

    def posttime
      'posttime'
    end

    def startime
      'startime'
    end
  end

  def initialize params
    @params = if params
                params.dup
              else
                EventStarFilter.default_filter
              end
  end

  def apply_star_filter events
    return events unless params.present?

    filter = params.dup

    if filter.include? "posttime"
      events = events.order("created_at DESC")
    elsif filter.include? "startime"
      events = events.order("stars_at DESC")
    else
      events = events.order("created_at DESC")
    end
    events
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
