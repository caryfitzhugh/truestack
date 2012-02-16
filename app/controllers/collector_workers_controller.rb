class CollectorWorkersController < ApplicationController

  def ingest
    key   = params[:key]
    nonce = params[:nonce]
    token = params[:token]

    # Nonce must be 32+ chars and a-f0-9
    if nonce =~ /^[0-9a-f]{31}[0-9a-f]+$/
      Rails.logger.info "Looking up access token for key: #{req_key}"
      access_token = AccessToken.where(key: req_key).limit(1).first
      if (access_token && access_token.valid_signature?(nonce, token))
        message = params[:message]
        access_token.user_application.latest_deployment.inject_message(message)
      end
    else
      render text: "Error", status: 404
    end
  end

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

  # GET /collector_workers/new
  # GET /collector_workers/new.json
  def new
    @collector_worker = CollectorWorker.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @collector_worker }
    end
  end

  # GET /collector_workers/1/edit
  def edit
    @collector_worker = CollectorWorker.find(params[:id])
  end

  # POST /collector_workers
  # POST /collector_workers.json
  def create
    @collector_worker = CollectorWorker.new(params[:collector_worker])

    respond_to do |format|
      if @collector_worker.save
        format.html { redirect_to @collector_worker, notice: 'Collector worker was successfully created.' }
        format.json { render json: @collector_worker, status: :created, location: @collector_worker }
      else
        format.html { render action: "new" }
        format.json { render json: @collector_worker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /collector_workers/1
  # PUT /collector_workers/1.json
  def update
    @collector_worker = CollectorWorker.find(params[:id])

    respond_to do |format|
      if @collector_worker.update_attributes(params[:collector_worker])
        format.html { redirect_to @collector_worker, notice: 'Collector worker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @collector_worker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collector_workers/1
  # DELETE /collector_workers/1.json
  def destroy
    @collector_worker = CollectorWorker.find(params[:id])
    @collector_worker.destroy

    respond_to do |format|
      format.html { redirect_to collector_workers_url }
      format.json { head :no_content }
    end
  end
end
