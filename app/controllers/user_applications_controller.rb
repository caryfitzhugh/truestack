class UserApplicationsController < ApplicationController
  TOKEN_METHODS = [ :create_metric_event, :create_browser_event, :create_request_event, :create_exception_event ]
  before_filter :access_token_required, :only => TOKEN_METHODS
  before_filter :authenticate_user!, :except =>  TOKEN_METHODS

  def create_metric_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    ::Rails.logger.info "Caught metric event"
    ::Rails.logger.info message.to_yaml

    app = @access_token.user_application
    tstart = message.delete(:tstart)
    name   = message.delete(:name)
    value  = message.delete(:value)
    meta_data  = message.delete(:meta_data) || {}

    app.add_metric(tstart, name, value, meta_data)

    head :accepted
  end

  def create_exception_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    ::Rails.logger.info "Caught exception event "
    ::Rails.logger.info message.to_yaml

    app = @access_token.user_application
    req_name = message.delete(:request_name)
    name     = message.delete(:exception_name)
    backtrace= message.delete(:backtrace)              || []
    tstart   = Time.parse(message.delete(:tstart))     rescue Time.now
    env      = message.delete(:env)                    || {}

    app.add_exception(req_name, name, tstart, backtrace, env)

    head :accepted
  end

  def create_browser_event
    ::Rails.logger.info "Caught browser event "
    ::Rails.logger.info params.to_yaml

    app = @access_token.user_application
    app.add_request(params[:request_id], params[:tstart], params[:tend])

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
