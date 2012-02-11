class DirectorController < ApplicationController
  def index
    collector = CollectorWorker.find_available();

    if collector
      # We found a collector to give them, redirect there.
      # ### Return 307 ###
      redirect_to collector.url, :status=>307
    else
      # We found nothing to give them.
      # ### Return 503 with Retry-After (60) ###
      response.headers['Retry-After'] = 30
      render :text=>"No available collectors, Retry", :status=>503
    end
  end
end
