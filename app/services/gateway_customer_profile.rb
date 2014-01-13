class GatewayCustomerProfile
  attr_reader :credit_card, :order

  def initialize(credit_card, order)
    @credit_card = credit_card
    @order = order
    fetch_customer_profile
  end

  private

  def fetch_customer_profile
    if missing_gateway_profile_id? && payment_gateway_is_stripe?
      if customer_profile.success?
        payment_profile = customer_profile.params['profile']['payment_profiles'] if customer_profile.params
        credit_card.update_column(:gateway_payment_profile_id, payment_profile['customer_payment_profile_id'])
      end

      customer_profile
    end
  end

  def missing_gateway_profile_id?
    credit_card.gateway_payment_profile_id.nil?
  end

  def payment_gateway_is_stripe?
    order.payments.last.payment_method.type != "Spree::Gateway::Stripe"
  end

  def authnet_gateway 
    authnet_gateway ||= ::ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
      login: ENV['AUTHORIZE_NET_LOGIN'],
      password: ENV['AUTHORIZE_NET_TRANSACTION_KEY']
    )
  end

  def customer_profile
    @customer_profile = authnet_gateway.get_customer_profile(
      customer_profile_id: credit_card.gateway_customer_profile_id)
  end
end
