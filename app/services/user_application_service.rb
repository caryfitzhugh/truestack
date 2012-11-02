module Services
  class UserApplicationService < ApplicationService
    def self.base_url; "apps" ; end

    # Create a new user application.
    # Requires a user token
    post "/" do
      user = authenticate(:user)
      application = UserApplication.new( name: params[:name], user: user )
      if application.save
        [200, application.id.to_s]
      else
        500
      end
    end

    delete "/:id" do
      user = authenticate(:user)
      application = UserApplication.where(user: user).where(id: params[:id]).first

      if application
        application.destroy
        200
      else
        404
      end
    end

    post "/:id/purge_data" do
      user = authenticate(:user)
      application = UserApplication.where(user: user).where(id: params[:id]).first

      if application
        application.purge!
        200
      else
        404
      end
    end

  end
end
