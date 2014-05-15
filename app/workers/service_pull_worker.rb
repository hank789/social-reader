class ServicePullWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(service_id)
    service = Service.find_by_id(service_id)
    items=service.get_home_timeline_items(service.since_id)
    last_item = items.first
    if last_item && last_item.id
      service.since_id = last_item.id
      service.save
    end
    # items = items.reverse
    items.each do |item|
      service.post item
    end
  end
end