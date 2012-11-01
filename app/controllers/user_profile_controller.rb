class UserProfileController < ApplicationController
  before_filter :authenticate_user!

  def show

  end

  def update
    redirect_to :action => :show
  end

  def reset_token
    current_user.api_token = SecureRandom.hex(16)
    current_user.save!
    redirect_to :action => :show
  end
end
