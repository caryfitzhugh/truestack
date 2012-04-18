class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user

    can :read, :all

    if user.member?
      can :manage, UserApplication do |user_app|
        user_app.try(:owner) == user
      end
    end
  end
end

class AdminAbility
  include CanCan::Ability

  def initialize(user)
    if user && user.admin?
      can :access, :rails_admin
      can :manage, :all
    end
  end
end


