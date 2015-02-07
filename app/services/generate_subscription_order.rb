class GenerateSubscriptionOrder
  include SubscriptionTransitions
  attr_reader :subscription

  class PaymentError < StandardError
  end

  def initialize(subscription)
    @subscription = subscription
  end

  def call
    return false unless @subscription.eligible_for_processing?
    begin
      create_next_order_with_payment
    rescue => error
      log_failure_and_continue(error)
    end
  end

  def create_next_order_with_payment
    previous_order = subscription.last_order
    # create a new order and populate the next order with the same line items
    previous_order.line_items.each do |line_item|
      order_populator.populate line_item.variant, line_item.quantity
    end

    transition_order_from_cart_to_payment!(next_order)

    ensure_profile_exists_for_payment_source(previous_order)
    ensure_credit_card_has_expiration_month

    next_order.create_payment!(payment_gateway_for_card(credit_card), credit_card)
    next_order.apply_employee_discount if previous_order.respond_to?(:has_employee_discount?) && previous_order.has_employee_discount?

    transition_order_from_payment_to_complete!(next_order)

    subscription.decrement_prepaid_duration!

    true
  end

  def ensure_profile_exists_for_payment_source(previous_order)
    GatewayCustomerProfile.new(credit_card, previous_order)
  end

  def payment_gateway_for_card(credit_card)
    @eligible_gateways ||= ::Spree::PaymentMethod.where(environment: Rails.env)
    if credit_card.payment_provider == 'Stripe'
      gateway = @eligible_gateways.where(type: 'Spree::Gateway::StripeGateway').first
    elsif credit_card.payment_provider == 'Auth.net'
      gateway = @eligible_gateways.where(type: 'Spree::Gateway::AuthorizeNetCim').first   
    end
    # attempt to use the credit card bogus gateway    
    gateway = @eligible_gateways.where(type: 'Spree::Gateway::Bogus').first unless gateway.present?         
        
    gateway.present? ? gateway : @eligible_gateways.first
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
    @credit_card ||= subscription.credit_card || store_credit_card_for_subscription
  end

  def order_populator
    @order_populator ||= ::Spree::OrderPopulator.new(next_order, ::Spree::Config[:currency])
  end

  def next_order
    @next_order ||= subscription.create_next_order!
  end
end

