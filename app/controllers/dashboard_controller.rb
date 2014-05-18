class DashboardController < ApplicationController
  respond_to :html

  before_filter :load_services
  before_filter :event_filter, only: :show
  before_filter :check_last_events
  before_filter :set_title


  def show
    # Fetch only 30 services.
    # If user needs more - point to Dashboard#services page
    @services_limit = 30

    @has_authorized_services = @services.count > 0
    @services_count = @services.count
    @services = @services.limit(@services_limit)

    @events = Event.load_events(current_user.id)
    @events = @event_filter.apply_filter(@events)
    @events = @events.limit(50).offset(params[:offset] || 0)

    @publicish_service_count = 1

    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
      format.atom { render layout: false }
    end
  end

  protected

  def load_services
    @services = current_user.services
  end

  def check_last_events
    if current_user
      current_user.services.each do |service|
        if (service.last_activity_at && Time.now.to_i - service.last_activity_at.to_time.to_i >= 90) || !service.last_activity_at
          service.last_activity_at = Time.now
          service.save
          ServicePullWorker.perform_async(service.id)
        end
      end
    end
  end

  def set_title
    @title = 'Dashboard'
  end
end
