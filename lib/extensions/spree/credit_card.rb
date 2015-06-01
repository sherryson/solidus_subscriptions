module SpreeSubscriptions
  module Extensions
    module Spree
      module CreditCard

        def payment_provider
          gateway_customer_profile_id.include?('cus_') ? 'Stripe' : 'Auth.net'
        rescue
          'Unknown'
        end

      end
    end
  end
end

::Spree::CreditCard.prepend SpreeSubscriptions::Extensions::Spree::CreditCard