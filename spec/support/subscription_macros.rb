module SubscriptionMacros
  include OrderMacros

  def setup_subscription_for(user)
    create_completed_subscription_order
    associate_subscription_to user
  end

  def associate_subscription_to(user)
    @subscription = Spree::Subscription.last
    @subscription.update_attribute(:user, user)
    @subscription.shipping_address.update_attribute(:user, user)
    @subscription.billing_address.update_attribute(:user, user)

    @order.update_attribute(:user, user)
  end
end
