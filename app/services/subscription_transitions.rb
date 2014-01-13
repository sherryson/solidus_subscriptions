module SubscriptionTransitions
  def transition_order_from_cart_to_address!(order)
    order.next!
    order.shipping_method = order.rate_hash.first.shipping_method
  end

  def transition_order_from_address_to_delivery!(order)
    order.next!
  end

  def transition_order_from_delivery_to_payment!(order)
    order.next!
  end

  def transition_order_from_payment_to_confirm!(order)
    order.next! unless order.completed?
  end

  def transition_order_from_confirm_to_complete!(order)
    order.next! unless order.completed?
  rescue StateMachine::InvalidTransition
    ::NotificationMailer.delay.subscription_payment_failure(order, subscription.retry_count)
    raise PaymentError
  end
end