module Admin
  class UsersController < BaseController
    respond_to :html, :json

    def index
      @users = User.all

      respond_with @users
    end

    def show
      @user = User.find(params[:id])

      respond_with @user
    end

    def new
      @user = User.new

      respond_with @user
    end

    def edit
      @user = User.find(params[:id])

      respond_with @user
    end

    def create
      @user = User.new(params[:user])
      @user.save

      respond_with @user, location: admin_user_path(@user)
    end

    def update
      [:password,:password_confirmation,:current_password].collect{|p| params[:user].delete(p) } if params[:user][:password].blank?

      @user = User.find(params[:id])
      @user.update_attributes(params[:user])

      respond_with @user, location: admin_user_path(@user)
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy

      respond_with @user
    end

    private

    def accessible_roles
      @accessible_roles = Role.accessible_by(current_ability)
    end
  end
end
