class AccessTokensController < ApplicationController
  # GET /access_tokens
  # GET /access_tokens.json
  def index
    @access_tokens = AccessToken.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @access_tokens }
    end
  end

  # GET /access_tokens/1
  # GET /access_tokens/1.json
  def show
    @access_token = AccessToken.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @access_token }
    end
  end

  # GET /access_tokens/new
  # GET /access_tokens/new.json
  def new
    @access_token = AccessToken.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @access_token }
    end
  end

  # GET /access_tokens/1/edit
  def edit
    @access_token = AccessToken.find(params[:id])
  end

  # POST /access_tokens
  # POST /access_tokens.json
  def create
    @access_token = AccessToken.new(params[:access_token])

    respond_to do |format|
      if @access_token.save
        format.html { redirect_to @access_token, notice: 'Access token was successfully created.' }
        format.json { render json: @access_token, status: :created, location: @access_token }
      else
        format.html { render action: "new" }
        format.json { render json: @access_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /access_tokens/1
  # PUT /access_tokens/1.json
  def update
    @access_token = AccessToken.find(params[:id])

    respond_to do |format|
      if @access_token.update_attributes(params[:access_token])
        format.html { redirect_to @access_token, notice: 'Access token was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @access_token.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /access_tokens/1
  # DELETE /access_tokens/1.json
  def destroy
    @access_token = AccessToken.find(params[:id])
    @access_token.destroy

    respond_to do |format|
      format.html { redirect_to access_tokens_url }
      format.json { head :no_content }
    end
  end
end
