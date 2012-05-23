class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_path, :alert => exception.message
  end

  private

  def access_token_required
    key   = params["Truestack-Access-Key"]   || request.headers['Truestack-Access-Key']

    access_token = AccessToken.where(key: key).limit(1).first
    if (access_token)
      @access_token = access_token
    else
      head 403
    end
  end

end
