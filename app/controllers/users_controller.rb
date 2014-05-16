class UsersController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]
  layout :determine_layout

  def show
    @user = User.find_by_username!(params[:username])
    @title = @user.name
  end

  def determine_layout
    if current_user
      'navless'
    else
      'public_users'
    end
  end
end
