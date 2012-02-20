class UserApplicationsController < ApplicationController
  before_filter :access_token_required, :only => [:create_event]

  def create_event
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    app = access_token.user_application
    if (message[:type] == 'request' )
      #name, timestamp, data
      app.add_request(message[:name], message[:timestamp], :data => message[:data])
    end
    app.save!
    head :accepted
  end

  def show
    @user_application = UserApplication.find(params[:id])
    @user_application.latest_deployment
  end

  def index
    @user_applications = UserApplication.all
  end
end
