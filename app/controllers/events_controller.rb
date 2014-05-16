class EventsController < ApplicationController

  before_action :load_event

  def favorite
    @event.favorite
    render :text => "1"
  end

  def unfavorite
    @event.unfavorite
    render :text => "1"
  end

  private

  def load_event
    @event = Event.find(params[:id])
  end

end
