class UserApplicationsController < ApplicationController
  def show
    @user_application = UserApplication.find(params[:id])
    @user_application.latest_deployment
  end

  def index
    @user_applications = UserApplication.all
  end
end
