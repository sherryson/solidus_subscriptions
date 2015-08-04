class AbilityDecorator
  include CanCan::Ability

  def initialize(user)
    can :read, Spree::Subscription, user_id: user.id
    can :read, Spree::SubscriptionItem, subscription: { user_id: user.id}
  end
end

Spree::Ability.register_ability(AbilityDecorator)
