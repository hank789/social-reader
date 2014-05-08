class LimitsToMysql < ActiveRecord::Migration
  def up
    return unless ActiveRecord::Base.configurations[Rails.env]['adapter'] =~ /^mysql/

  end
end
