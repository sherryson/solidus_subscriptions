module Spree
  class AbilityDecorator
    include CanCan::Ability
    def initialize(user)
      can :manage, Spree::Subscription do |subscription|
        subscription.user == user
      end
    end
  end
end

Spree::Ability.register_ability(Spree::AbilityDecorator)
