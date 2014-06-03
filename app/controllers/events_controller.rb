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
    lasted_event = Event.find(cookies['lasted_event_id'])
    Event.where("created_at >= ? and created_at <= ?",@event.created_at,lasted_event.created_at).update_all(action: Event::READ)
    respond_to do |format|
      format.js {render inline: "$('.content_list').html('');Pager.init(50, true);" }
    end
  end

  private

  def load_event
    @event = Event.find(params[:id])
  end

end
