class DeploymentsController < ApplicationController
  before_filter :access_token_required, :only => [:create]

  def create
    @access_token.user_application.deploy!(ActiveSupport::JSON.decode(request.body).symbolize_keys)
    head :accepted
  end

  def show
    @deployment = Deployment.find(params[:id])
  end
end
