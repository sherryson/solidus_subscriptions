class GenerateSubscriptionOrder

  class PaymentError < StandardError
  end

  def initialize(subscription)
    @subscription = subscription
  end

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
    order.next!
  end

  def transition_order_from_confirm_to_complete!(order, sub)
    order.next!
  rescue StateMachine::InvalidTransition
    ::NotificationMailer.delay.subscription_payment_failure(order, sub.retry_count)
    raise PaymentError
  end

  def call
    sub = @subscription
    begin
      previous_order = sub.last_order
      next_order = sub.orders.build({
        user: previous_order.user,
        email: previous_order.email,
        repeat_order: true,

        bill_address: sub.bill_address,
        ship_address: sub.ship_address

      }, without_protection: true)

      next_order.save!

      order_populator = ::Spree::OrderPopulator.new(next_order, ::Spree::Config[:currency])

      variants = previous_order.line_items.inject({}) do |hash, li|
        if li.variant.product.subscribable_variants.include? li.variant
          hash[li.variant.id] = li.quantity
        end

        hash
      end

      order_populator.populate({variants: variants})

      transition_order_from_cart_to_address!(next_order)
      transition_order_from_address_to_delivery!(next_order)
      transition_order_from_delivery_to_payment!(next_order)


      cc = find_or_create_credit_card(sub)
      ensure_profile_exists_for_payment_source(cc, previous_order)
      ensure_credit_card_has_expiration_month(cc)

      next_order.payments.create!({
        payment_method: previous_order.payments.last.payment_method,
        source: cc,
        amount: next_order.update_totals,
        state: 'checkout'
      }, without_protection: true)

      next_order.apply_employee_discount if previous_order.respond_to?(:has_employee_discount?) && previous_order.has_employee_discount?
      transition_order_from_payment_to_confirm!(next_order)
      transition_order_from_confirm_to_complete!(next_order, sub)

      puts "Order #{next_order.number} created for subscription ##{sub.id}."
      return true
    rescue => e
      ::SubscriptionLog.create(order_id: next_order.id, reason: e.to_s)
      sub.failure_count += 1
      sub.save
      puts "#{e}"
      puts "Error Creating Order for #{sub.id}. #{e}"
    end
  end

  def ensure_profile_exists_for_payment_source(cc, previous_order)
    if cc.gateway_payment_profile_id.nil? && previous_order.payments.last.payment_method.type != "Spree::Gateway::Stripe"

      authnet_gateway = ::ActiveMerchant::Billing::AuthorizeNetCimGateway.new(login: ENV['AUTHORIZE_NET_LOGIN'],
                                                                              password: ENV['AUTHORIZE_NET_TRANSACTION_KEY'])

      customer_profile = authnet_gateway.get_customer_profile(customer_profile_id: cc.gateway_customer_profile_id)

      if customer_profile.success?
        payment_profile  = customer_profile.params['profile']['payment_profiles'] if customer_profile.params
        puts payment_profile['customer_payment_profile_id']
        cc.update_column(:gateway_payment_profile_id, payment_profile['customer_payment_profile_id'])
      end
    end
  end

  def ensure_credit_card_has_expiration_month(cc)
    if cc.month.nil?
      cc.month = 1
      cc.year = 2020
      cc.save
    end
  end

  def find_or_create_credit_card(subscription)
    subscription.credit_card || store_credit_card_for_subscription(subscription)
  end

  def store_credit_card_for_subscription(subscription)
    subscription.credit_card = subscription.last_order.payments.where('amount > 0').where(state: 'completed').last.source
    subscription.credit_card
  end
end

