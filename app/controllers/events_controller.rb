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

  private

  def load_event
    @event = Event.find(params[:id])
  end

end
