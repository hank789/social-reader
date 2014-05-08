class Admin::DashboardController < Admin::ApplicationController
  def index
    @services = Service.order("created_at DESC").limit(10)
    @users = User.order("created_at DESC").limit(10)
    #@groups = Group.order("created_at DESC").limit(10)
  end
end
