class SignupsController < ApplicationController
  layout "signups"

  def thanks
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
        Pony.mail(:to => 'keep.me.posted@truestack.com', :from => 'email@truestack.com', :subject => 'User is interested in following us', :body =>params[:signup].to_yaml)

        format.html { redirect_to action:"thanks", notice: 'Signup was successfully created.' }
        format.json { render json: @signup, status: :created, location: @signup }
      else
        format.html { render action: "new" }
        format.json { render json: @signup.errors, status: :unprocessable_entity }
      end
    end
  end
end
