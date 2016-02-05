module SubscriptionMacros
  include OrderMacros

  def setup_subscriptions_for(user)
    create_completed_subscription_order user    
  end

end
