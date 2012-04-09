class UserApplicationsController < ApplicationController
  before_filter :access_token_required, :only => [:create_event, :create_browser_event, :create_request_event]

  def create_browser_event
    ::Rails.logger.info "Caught browser event "
    ::Rails.logger.info params.to_yaml

    app = @access_token.user_application
    app.add_request(message[:request_id], message[:tstart], message[:tend])

    head :accepted
  end

  # request_id:  (unique token)
  # name: controller#action
  # actions:
  #   type => controller | model | helper | view | browser | lib
  #   tstart
  #   tend
  #   name: klass#method
  #
  def create_request_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    app = @access_token.user_application
    app.add_request(message[:name], message[:request_id], message[:actions])

    head :accepted
  end

  def create_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    app = @access_token.user_application
    if (message[:type] == 'request' )
      #name, timestamp, data
      app.add_request(message[:name], message[:timestamp], message[:actions])
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
