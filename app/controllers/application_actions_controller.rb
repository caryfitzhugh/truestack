class ApplicationActionsController < ApplicationController
  def create
    key   = params[:key]
    nonce = params[:nonce]
    token = params[:token]

    # Nonce must be 32+ chars and a-f0-9
    if nonce =~ /^[0-9a-f]{31}[0-9a-f]+$/
      Rails.logger.info "Looking up access token for key: #{key}"
      access_token = AccessToken.where(key: key).limit(1).first
      if (access_token && access_token.valid_signature?(nonce, token))
        message = params[:message]
        deployment= access_token.user_application.latest_deployment
        deployment.inject_message(message)
        deployment.save!
        head :accepted
      else
        head 403
      end
    else
      head 403
    end
  end
end
