module Spree
  module CreditCardExtensions
    def payment_provider
      gateway_customer_profile_id.include?('cus_') ? 'Stripe' : 'Unknown'
    rescue
      'Unknown'
    end
  end
end

::Spree::CreditCard.prepend ::Spree::CreditCardExtensions
