module Services
  class ApplicationService < Sinatra::Base
    def self.rack_base(base)
      [base, self.base_url].compact.join("/")
    end

    private

    def self.base_url
      nil
    end

    def authenticate(type=nil)
      # First get the user's token
      key   = params["Truestack-Access-Key"] || request.env['HTTP_TRUESTACK_ACCESS_KEY'] || request.env['Truestack-Access-Key']

      if type == :application
        access_token = AccessToken.where(key: key).limit(1).first

        if (access_token)
          access_token.user_application
        else
          halt 403
        end

      elsif type == :user
        user = User.where(api_token: key).limit(1).first
        if (user)
          user
        else
          halt 403
        end
      else
        halt 403
      end
    end

    def send_blank_gif
      [200,{'Content-Type' => 'image/gif'},  Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==")]
    end
  end
end
