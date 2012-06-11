class UserApplicationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_current_user_application, :except => [:new]

  def show
    @user_application = UserApplication.find(params[:id])
    @deployments      = @user_application.deployments.where(:tstart.gte => get_window_start_time).asc(:tstart)
    @slices           = ApplicationTimeSlice.slices_for(@user_application, get_window_start_time).asc(:timestamp)
  end

  def index
    @user_applications = UserApplication.where(user: current_user)
  end

  def new
    @user_application = UserApplication.new
  end

  def edit
    @user_application = UserApplication.find(params[:id])

  end

  def purge_data
    @user_application = UserApplication.find(params[:app_id])
    @user_application.purge!
    redirect_to edit_app_path(@user_application)
  end

  def reset_token
    @user_application = UserApplication.find(params[:app_id])
    @user_application.access_token.destroy if @user_application.access_token
    @user_application.create_access_token
    @user_application.save!

    redirect_to edit_app_path(@user_application)
  end

  def create
    @user_application = UserApplication.new(params[:user_application])
    @user_application.user = current_user

    if @user_application.save
      redirect_to app_path(@user_application)
    else
      render :action => "new"
    end
  end

  private

  def set_current_user_application
    @current_user_application = UserApplication.where(:_id => params[:id]).first
  end

  def get_window_start_time
    case (params[:window_size] || 'default').downcase
    when '1_day'
      1.day.ago
    when '7_day'
      7.day.ago
    else
      30.days.ago
    end
  end
end
