class DashboardController < ApplicationController
  respond_to :html

  before_filter :load_services
  before_filter :event_filter, only: :show
  before_filter :check_last_events, only: :show


  def show
    @title = 'Dashboard'
    @events = Event.load_events(current_user.id)
    @events = @event_filter.apply_filter(@events,current_user.id)
    @events = @events.limit(50).offset(params[:offset] || 0)

    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
    end
  end

  def stars
    @title = 'Stars'
    @events = Event.load_star_events(current_user.id)
    @events = @events.limit(50).offset(params[:offset] || 0)
    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
    end
  end

  def analytics
    @title = 'Analytics'
  end

  def discovery
    @title = 'Discovery'
  end

  protected

  def load_services
    # Fetch only 30 services.
    # If user needs more - point to Dashboard#services page
    @services = current_user.services

    @services_limit = 30
    @has_authorized_services = @services.count > 0
    @services_count = @services.count
    @services = @services.limit(@services_limit)

    @publicish_service_count = 1
  end

  def check_last_events
    if current_user
      @last_unread_message = {
          Service::IMPORTANT => {'priority'=> 'IMPORTANT', 'since'=>'','message'=>'','count'=>0},
          Service::NORMAL   => {'priority'=> 'NORMAL', 'since'=>'','message'=>'','count'=>0},
          Service::LOW => {'priority'=> 'LOW', 'since'=>'','message'=>'','count'=>0}
      }
      @last_unread_count = 0
      current_user.services.each do |service|
        if @last_unread_count >=1
          @last_unread_message[service.priority]['message'] += " | #{service.last_unread_count}(#{service.provider}) unread "
        else
          @last_unread_message[service.priority]['message'] += "#{service.last_unread_count}(#{service.provider}) unread "
        end
        @last_unread_message[service.priority]['count'] += service.last_unread_count
        @last_unread_message[service.priority]['since'] = "since #{service.last_read_time.stamp('Aug 21, 2011 9:23pm')}"
        @last_unread_count += service.last_unread_count
        if service.last_activity_at && Time.now.to_i - service.last_activity_at.to_time.to_i >= 90
          service.last_activity_at = Time.now
          if params[:offset].nil?
            if @event_filter.include_key?(service.priority)
              service.last_unread_count = 0
              service.last_read_time = Time.now
            end
          end
          service.save
          ServicePullWorker.perform_async(service.id)
        end
      end
    end
  end
end
