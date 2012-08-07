class UserApplicationFallbackController < ApplicationController
  TOKEN_METHODS = [ :create_browser_event, :create_request_event, :create_exception_event , :create_startup_event]
  before_filter :access_token_required, :only => TOKEN_METHODS
  before_filter :authenticate_user!, :except =>  TOKEN_METHODS

  #    :type => :startup,
  #    :host_id   => host_id,
  #    :commit_id => commit_id,
  #    :tstart    => Time.now,
  #    :methods => instrumented_method_names
  def create_startup_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    ::Rails.logger.info "Caught startup event"
    ::Rails.logger.info message.to_yaml

    app = @access_token.user_application

    tstart = message.delete(:tstart)
    host_id = message.delete(:host_id)
    commit_id  = message.delete(:commit_id)
    methods  = message.delete(:methods) || []

    app.add_startup(tstart, host_id, commit_id, methods)

    head :accepted
  end

  def create_exception_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    ::Rails.logger.info "Caught exception event "
    ::Rails.logger.info message.to_yaml

    app = @access_token.user_application
    req_name = message.delete(:request_name)
    tstart   = message.delete(:tstart)
    name     = message.delete(:exception_name)
    backtrace= message.delete(:backtrace)              || []
    failed_in_method  = message.delete(:failed_in_method)
    actions  = message.delete(:actions)
    env      = message.delete(:env)                    || {}

    app.add_exception(req_name, name, failed_in_method, actions, tstart, backtrace, env)

    head :accepted
  end

  def create_browser_event
    ::Rails.logger.info "Caught browser event "
    ::Rails.logger.info params.to_yaml

    app = @access_token.user_application
    name = params[:truestack][:name]
    app.add_browser_ready_timing(name.underscore, params[:truestack][:tstart].to_i, params[:truestack][:tend].to_i)

    send_blank_gif
  end

  # name: controller#action
  # actions:
  #   type => controller | model | helper | view | browser | lib
  #   name: klass#method
  #   tstart
  #   tend
  #
  def create_request_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    app = @access_token.user_application
    app.add_request(message[:name], message[:actions])

    head :accepted
  end

  private

  def send_blank_gif
    send_data(Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), :type => "image/gif", :disposition => "inline")
  end
end
