class DeploymentsController < ApplicationController
  before_filter :access_token_required, :only => [:create]

  def create
    message = ActiveSupport::JSON.decode(request.body).symbolize_keys
    commit_id = message.delete(:commit_id)
    @access_token.user_application.deploy!(commit_id, message)
  end

  def show
    @deployment = Deployment.find(params[:id])
  end
end
