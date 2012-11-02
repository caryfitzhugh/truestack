module Services
  class CollectorService < ApplicationService
    def self.base_url; "collector" ; end

    # Application is starting up -- get the information
    post "/startup" do
      application = authenticate(:application)
      message = ActiveSupport::JSON.decode(request.body).symbolize_keys
      ::Rails.logger.info "Caught startup event"
      ::Rails.logger.info message.to_yaml

      tstart      = message.delete(:tstart)
      host_id     = message.delete(:host_id)
      commit_id   = message.delete(:commit_id)
      methods     = message.delete(:methods) || []

      application.add_startup(tstart, host_id, commit_id, methods)

      202
    end

    # Application received an exception
    post "/exception" do
      application = authenticate(:application)
      message = ActiveSupport::JSON.decode(request.body).symbolize_keys
      ::Rails.logger.info "Caught exception event "
      ::Rails.logger.info message.to_yaml

      req_name          = message.delete(:request_name)
      tstart            = message.delete(:tstart)
      name              = message.delete(:exception_name)
      backtrace         = message.delete(:backtrace)              || []
      failed_in_method  = message.delete(:failed_in_method)
      actions           = message.delete(:actions)
      env               = message.delete(:env)                    || {}

      application.add_exception(req_name, name, failed_in_method, actions, tstart, backtrace, env)

      202
    end

    # Ingest a standard request from the user_application
    post "/request" do
      application = authenticate(:application)
      message = ActiveSupport::JSON.decode(request.body).symbolize_keys
      application.add_request(message[:name], message[:actions])

      202
    end

    # Track browser load times for this
    # This is where the JS will hit with page load times.
    get "/browser" do
      application = authenticate(:application)

      name = params[:truestack][:name]
      application.add_browser_ready_timing(name.underscore, params[:truestack][:tstart].to_i, params[:truestack][:tend].to_i)

      send_blank_gif
    end

  end
end
