module SpreeSubscriptions
  module Extensions
    module Spree
      module CreditCard
        extend ActiveSupport::Concern

        def payment_provider
          gateway_customer_profile_id.include?('cus_') ? 'Stripe' : 'Auth.net'
        rescue
          'Unknown'
        end

      end
    end
  end
end

::Spree::CreditCard.send(:include, SpreeSubscriptions::Extensions::Spree::CreditCard)
