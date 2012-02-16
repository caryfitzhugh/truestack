class CollectorWorkersController < ApplicationController
  # GET /collector_workers
  # GET /collector_workers.json
  def index
    @collector_workers = CollectorWorker.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @collector_workers }
    end
  end

  # GET /collector_workers/1
  # GET /collector_workers/1.json
  def show
    @collector_worker = CollectorWorker.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @collector_worker }
    end
  end
end
