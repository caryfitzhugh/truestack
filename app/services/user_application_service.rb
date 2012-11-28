module Services
  class UserApplicationService < ApplicationService
    def self.base_url; "apps" ; end

    # Create a new user application.
    # Requires a user token
    post "/" do
      user = authenticate(:user)
      application = UserApplication.new(user: user, name: params[:name])

      if application.save
        # This is the TS director URL
        # It gives the acces_toekn key
        url = "http://#{application.access_token.key.to_s}@#{request.host}:#{request.port}/"
        [200, {:url => url, :id => application.id}.to_json]
      else
        [500, application.errors.to_json]
      end
    end

    delete "/:id" do
      application = authenticate(:user_application)
      application.destroy
      200
    end

    post "/:id/purge_data" do
      application = authenticate(:user_application)
      application.purge!
      200
    end

    get "/:id/deployments" do
      application = authenticate(:user_application)
      [200, application.deployments.map(&:attributes).to_json]
    end
    get "/:id/time_slices" do
      application = authenticate(:user_application)
      [200, application.application_time_slices.map(&:attributes).to_json]
    end

    get "/:id/access_counters" do
      application = authenticate(:user_application)
      [200, application.access_counters.map {|ac| {start_on: ac.start_on.to_i, count:ac.count} }.to_json]
    end
  end
end
