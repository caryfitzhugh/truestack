class SignupsController < ApplicationController
  layout "signups"
  def thanks
    @signup = Signup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @signup }
    end
  end

  def new
    @signup = Signup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @signup }
    end
  end

  def create
    @signup = Signup.new(params[:signup])

    respond_to do |format|
      if @signup.save
        format.html { redirect_to action:"thanks", notice: 'Signup was successfully created.' }
        format.json { render json: @signup, status: :created, location: @signup }
      else
        format.html { render action: "new" }
        format.json { render json: @signup.errors, status: :unprocessable_entity }
      end
    end
  end
end
