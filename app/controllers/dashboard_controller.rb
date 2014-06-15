class DashboardController < ApplicationController
  respond_to :html

  before_filter :load_services
  before_filter :event_filter, only: [:show, :archive]
  before_filter :check_last_events, only: :show


  def show
    @title = 'Dashboard'
    @events = Event.load_events(current_user.id)
    @events = @event_filter.apply_filter(@events,current_user.id)
    @events = @events.limit(50).offset(params[:offset] || 0)
    @note = Note.new
    @events_all_unread_count = 0
    if (params[:offset] == "0" || params[:offset].nil?) && @events.first
      cookies['lasted_event_id'] = @events.first.id
      @events_all_unread_count = Event.where(user_id: current_user.id, action: Event::UNREAD).count
    end

    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
    end
  end

  def archive
    @title = 'Archive'
    @events = Event.load_archive_events(current_user.id)
    @events = @event_filter.apply_filter(@events,current_user.id)
    @events = @events.limit(50).offset(params[:offset] || 0)
    @note = Note.new
    if params[:offset] == "0" && @events.first
      cookies['lasted_event_id'] = @events.first.id
    end

    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
    end
  end

  def stars
    filters = cookies['event_star_filter'].split(',') if cookies['event_star_filter'].present?
    @event_filter ||= EventStarFilter.new(filters)
    @title = 'Stars'
    @events = Event.load_star_events(current_user.id)
    @events = @event_filter.apply_star_filter(@events)
    @events = @events.limit(50).offset(params[:offset] || 0)
    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
    end
  end

  def analytics
    @title = 'Analytics'
    respond_to do |format|
      format.html
      format.js do
        fetch_graph
      end
    end
  end
  def fetch_graph
    @log = Event.graph_log(current_user.id).to_json
    @success = true

  end

  protected

  def load_services
    # Fetch only 30 services.
    # If user needs more - point to Dashboard#services page
    @services = current_user.services

    @services_limit = 30
    @has_authorized_services = @services.count > 0
    @services_count = @services.count

    @publicish_service_count = 1
  end

  def check_last_events
    @last_unread_count = 0
    @last_read_time = Time.now
    if params[:offset] == "0" || params[:offset].nil?
      current_user.services.each do |service|
        if @last_read_time > service.last_read_time
          @last_read_time = service.last_read_time
        end
        @last_unread_count += service.last_unread_count
        if params[:offset] == "0" && service.last_activity_at && Time.now.to_i - service.last_activity_at.to_time.to_i >= 90
          service.last_activity_at = Time.now

          service.last_unread_count = 0
          service.last_read_time = Time.now

          service.save
          ServicePullWorker.perform_async(service.id)
        end
      end
    end
  end
end
