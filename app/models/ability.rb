class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user

    if user.role? :admin
      can :manage, :all
    elsif user.role? :member
      can :manage, UserApplication do |user_app|
        user_app.try(:owner) == user
      end
    end
  end
end



