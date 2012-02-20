class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def access_token_required
    key   = params["TrueStack-Access-Key"]
    token = params["TrueStack-Access-Token"]
    nonce = params["TrueStack-Access-Nonce"]

    # Nonce must be 32+ chars and a-f0-9
    if nonce =~ /^[0-9a-f]{31}[0-9a-f]+$/
      Rails.logger.info "Looking up access token for key: #{key}"
      access_token = AccessToken.where(key: key).limit(1).first
      if (access_token && access_token.valid_signature?(nonce, token))
        @access_token = access_token
      else
        head 403
      end
    else
      head 403
    end
  end
end
