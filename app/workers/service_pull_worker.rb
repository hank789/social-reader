class ServicePullWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(service_id)
    service = Service.find_by_id(service_id)
    items=service.get_home_timeline_items(service.since_id)
    last_item = items.first
    if last_item && last_item['id']
      case service.provider
        when 'facebook'
          service.since_id = last_item['created_time'].to_datetime.to_i
        when 'twitter'
          service.since_id = last_item['id']
        when 'instagram'
          service.since_id = last_item['id']
        else
          service.since_id = last_item['created_at'].to_datetime
      end
      service.last_unread_count += items.count
      service.save
    end
    items = items.reverse
    items.each do |item|
      service.post item
    end
  end
end