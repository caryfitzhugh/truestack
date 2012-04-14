class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :get_user

  private

  def get_user
    @current_user ||= current_user
  end

  def access_token_required
    key   = params["TrueStack-Access-Key"]   || request.headers['TrueStack-Access-Key']

    access_token = AccessToken.where(key: key).limit(1).first
    if (access_token)
      @access_token = access_token
    else
      head 403
    end
  end
end
