class EventsController < ApplicationController

  before_action :load_event

  def favorite
    @event.favorite(current_user.id)
    render :text => "1"
  end

  def unfavorite
    @event.unfavorite(current_user.id)
    render :text => "1"
  end

  def mark_above_as_read
    filter = []
    if cookies['event_filter'].present?
      filter = cookies['event_filter'].split(',')
    end

    lasted_event = Event.find(cookies['lasted_event_id'])
    services_ids = nil
    if params[:service].present?
      services_ids = params[:service]
    elsif !filter.empty?
      services_ids = filter[0].to_i
    end
    if services_ids.nil?
      Event.where(user_id: current_user.id, created_at: @event.created_at..lasted_event.created_at).update_all(action: Event::READ, read_at: Time.now)
    else
      Event.where(service_id: services_ids, user_id: current_user.id, created_at: @event.created_at..lasted_event.created_at).update_all(action: Event::READ, read_at: Time.now)
    end

    respond_to do |format|
      format.js {render inline: "$('.content_list').html('');Pager.init(50, true);" }
    end
  end

  private

  def load_event
    @event = Event.find(params[:id])
  end

end
