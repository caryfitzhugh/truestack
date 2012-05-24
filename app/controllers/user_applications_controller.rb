class UserApplicationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_current_user_application, :except => [:new]

  def show
    @user_application = UserApplication.find(params[:id])
    type, duration    = TimeSlice.decode_window_size(params[:window_size])
    @slices           = type.find_slices(@user_application, duration)
  end

  def index
    @user_applications = UserApplication.all
  end

  def new
    @user_application = UserApplication.new
  end

  def edit
    @user_application = UserApplication.find(params[:id])

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
    @user_application.account = current_user.account

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
end
