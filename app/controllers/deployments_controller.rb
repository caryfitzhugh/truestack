class DeploymentsController < ApplicationController
  def show
    @deployment = Deployment.find(params[:id])
  end
  def debug_create_data
    @deployment = Deployment.find(params[:id])

    (0...(500+rand(100))).each do |i|
      @deployment.add_request("action#number#{i}", {
        'app:foo' => {s: rand(100), d: rand(1000)},
        'app:baz' => {s: rand(100), d: rand(1000)},
        'app:bar' => {s: rand(100), d: rand(1000)},
        'db:foo' => {s: rand(100), d: rand(1000)},
        'db:bar' => {s: rand(100), d: rand(1000)},
        'db:baz' => {s: rand(100), d: rand(1000)},
        'view:foo' => {s: rand(100), d: rand(1000)},
        'view:bar' => {s: rand(100), d: rand(1000)},
        'view:baz' => {s: rand(100), d: rand(1000)},
        'browser:ready' => {s: rand(100), d: rand(1000)}
      })
    end
    @deployment.save!
    redirect_to deployment_path(@deployment)
  end
  def create
    raise 'not implemented'
  end
end
