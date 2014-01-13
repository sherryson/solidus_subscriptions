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

    transition_order_from_cart_to_payment!(next_order)

    ensure_profile_exists_for_payment_source(previous_order)
    ensure_credit_card_has_expiration_month

    next_order.create_payment!(previous_order.payment_method, credit_card)
    next_order.apply_employee_discount if previous_order.respond_to?(:has_employee_discount?) && previous_order.has_employee_discount?

    transition_order_from_payment_to_complete!(next_order)

    subscription.decrement_prepaid_duration!

    true
  end

  def ensure_profile_exists_for_payment_source(previous_order)
    GatewayCustomerProfile.new(credit_card, previous_order)
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
    subscription.increment_failure_count
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

