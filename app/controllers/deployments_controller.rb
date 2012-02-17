class DeploymentsController < ApplicationController
  def show
    @deployment = Deployment.find(params[:id])
  end
  def create
    raise 'not implemented'
  end
end
