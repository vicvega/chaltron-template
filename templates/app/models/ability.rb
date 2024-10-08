class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
    user ||= Chaltron::User.new
    can :destroy, Chaltron::Login, {user:}

    if user.role?(:user_admin)
      can :manage, Chaltron::User
      if Chaltron.ldap_allow_all
        cannot :edit, Chaltron::User, {provider: "ldap"}
        cannot :destroy, Chaltron::User, {provider: "ldap"}
      end
      can :read, Chaltron::Log, category: "user_admin"
    end
    can :read, Chaltron::Log if user.role?(:admin)
  end
end
