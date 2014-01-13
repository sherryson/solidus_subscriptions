class GenerateSubscriptionOrder
  include SubscriptionTransitions
  attr_reader :subscription

  class PaymentError < StandardError
  end

  def initialize(subscription)
    @subscription = subscription
  end

  def call
    begin
      create_next_order_with_payment
    rescue => error
      log_failure_and_continue(error)
    end
  end

  def create_next_order_with_payment
    previous_order = subscription.last_order

    order_populator.populate({variants: previous_order.line_items_variants})

    transition_order_from_cart_to_address!(next_order)
    transition_order_from_address_to_delivery!(next_order)
    transition_order_from_delivery_to_payment!(next_order)

    ensure_profile_exists_for_payment_source(previous_order)
    ensure_credit_card_has_expiration_month

    next_order.create_payment!(previous_order.payment_method, credit_card)

    next_order.apply_employee_discount if previous_order.respond_to?(:has_employee_discount?) && previous_order.has_employee_discount?

    transition_order_from_payment_to_confirm!(next_order)
    transition_order_from_confirm_to_complete!(next_order)

    subscription.decrement_prepaid_duration!

    true
  end

  def ensure_profile_exists_for_payment_source(previous_order)
    if credit_card.gateway_payment_profile_id.nil? && previous_order.payments.last.payment_method.type != "Spree::Gateway::Stripe"

      authnet_gateway = ::ActiveMerchant::Billing::AuthorizeNetCimGateway.new(login: ENV['AUTHORIZE_NET_LOGIN'],
                                                                              password: ENV['AUTHORIZE_NET_TRANSACTION_KEY'])

      customer_profile = authnet_gateway.get_customer_profile(customer_profile_id: credit_card.gateway_customer_profile_id)

      if customer_profile.success?
        payment_profile  = customer_profile.params['profile']['payment_profiles'] if customer_profile.params
        puts payment_profile['customer_payment_profile_id']
        credit_card.update_column(:gateway_payment_profile_id, payment_profile['customer_payment_profile_id'])
      end
    end
  end

  def ensure_credit_card_has_expiration_month
    if credit_card.month.nil?
      credit_card.month = 1
      credit_card.year = 2020
      credit_card.save
    end
  end

  def store_credit_card_for_subscription
    subscription.credit_card = subscription.last_order_credit_card
  end

  private

  def log_failure_and_continue(error)
    ::SubscriptionLog.create(order_id: next_order.id, reason: error.to_s)
    subscription.failure_count += 1
    subscription.save
  end

  def credit_card
    @credit_card ||= subscription.credit_card || store_credit_card_for_subscription(subscription)
  end

  def order_populator
    @order_populator ||= ::Spree::OrderPopulator.new(next_order, ::Spree::Config[:currency])
  end

  def next_order
    @next_order ||= subscription.create_next_order!
  end
end

