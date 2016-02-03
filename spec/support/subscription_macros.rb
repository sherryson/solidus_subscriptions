module SubscriptionMacros
  include OrderMacros

  def setup_subscription_for(user)
    create_completed_subscription_order
    associate_subscription_to user
  end

  def associate_subscription_to(user)
    @subscription = Spree::Subscription.last
    @subscription.update_attribute(:user, user)
    assign_user_to :shipping_address, user
    assign_user_to :billing_address, user

    @order.update_attribute(:user, user)
  end

  def assign_user_to(address_type, user)
    copy = @subscription.send(address_type).dup
    copy.update_attribute(:user, user)
    @subscription.send("#{address_type}=", copy)
  end
end
