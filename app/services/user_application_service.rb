module Services
  class UserApplicationService < ApplicationService
    def self.base_url; "apps" ; end

    # Create a new user application.
    # Requires a user token
    post "/" do
      user = authenticate(:user)
      application = UserApplication.new(user: user, name: params[:name])

      if application.save
        [200, application.id.to_s]
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

    get "/:id/access_counters" do
      application = authenticate(:user_application)
      [200, application.access_counters.map {|ac| {start_on: ac.start_on.to_i, count:ac.count} }.to_json]
    end
  end
end
