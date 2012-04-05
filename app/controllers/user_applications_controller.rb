class UserApplicationsController < ApplicationController
  before_filter :access_token_required, :only => [:create_event, :create_browser_event]

  def create_browser_event
    ::Rails.logger.info "Caught browser event "
    ::Rails.logger.info params.to_yaml

    head :200
  end

  def create_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    app = @access_token.user_application
    if (message[:type] == 'request' )
      #name, timestamp, data
      app.add_request(message[:name], message[:timestamp], :data => message[:data])
    end
    head :accepted
  end

  def show
    @user_application = UserApplication.find(params[:id])
    @user_application.latest_deployment
  end

  def index
    @user_applications = UserApplication.all
  end

  def new
    @user_application = UserApplication.new
  end

  def create
    @user_application = UserApplication.new(params[:user_application])
    if @user_application.save
      redirect_to user_application_path(@user_application)
    else
      render :action => "new"
    end
  end
end
