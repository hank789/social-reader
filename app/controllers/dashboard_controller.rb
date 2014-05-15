class DashboardController < ApplicationController
  respond_to :html

  before_filter :load_services, except: [:services]
  before_filter :event_filter, only: :show
  before_filter :check_last_events


  def show
    # Fetch only 30 services.
    # If user needs more - point to Dashboard#services page
    @services_limit = 30

    # @groups = current_user.authorized_groups.sort_by(&:human_name)
    @has_authorized_services = @services.count > 0
    @services_count = @services.count
    @services = @services.limit(@services_limit)

    @events = Event.load_events(current_user.id)
    @events = @event_filter.apply_filter(@events)
    @events = @events.limit(20).offset(params[:offset] || 0)

    # @last_push = current_user.recent_push

    @publicish_service_count = 1

    respond_to do |format|
      format.html
      format.json { pager_json("events/_events", @events.count) }
      format.atom { render layout: false }
    end
  end

  def services
    @services = case params[:scope]
                when 'personal' then
                  current_user.namespace.services
                when 'joined' then
                  current_user.authorized_services.joined(current_user)
                when 'owned' then
                  current_user.owned_services
                else
                  current_user.authorized_services
                end

    @services = @services.where(visibility_level: params[:visibility_level]) if params[:visibility_level].present?
    @services = @services.sort(@sort = params[:sort])
    @services = @services.page(params[:page]).per(30)
  end

  protected

  def load_services
    @services = current_user.owned_services
  end

  def default_filter
    params[:scope] = 'assigned-to-me' if params[:scope].blank?
    params[:state] = 'opened' if params[:state].blank?
    params[:authorized_only] = true
  end

  def check_last_events
    if current_user
      current_user.services.each do |service|
        if (service.last_activity_at && Time.now.to_i - service.last_activity_at.to_time.to_i >= 90) || (!service.last_activity_at && Time.now.to_i - service.updated_at.to_time.to_i >= 30)
          service.last_activity_at = Time.now
          service.save
          ServicePullWorker.perform_async(service.id)
        end
      end
    end
  end
end
