class BaseService
  attr_accessor :post, :current_user, :params

  def initialize(post, user, params)
    @post, @current_user, @params = post, user, params.dup
  end

  def abilities
    @abilities ||= begin
                     abilities = Six.new
                     abilities << Ability
                     abilities
                   end
  end

  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end

  def notification_service
    NotificationService.new
  end

  def event_service
    EventCreateService.new
  end

  def log_info message
    Gitlab::AppLogger.info message
  end
end
