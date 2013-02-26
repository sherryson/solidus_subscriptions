module SpreeSubscriptions
  module Extensions
    module Spree
      module Order
        extend ActiveSupport::Concern

        included do
          alias_method_chain :finalize!, :create_subscription
          belongs_to :subscription
          attr_accessible :subscription_id
        end

        def subscribable?
          line_items.any? { |li| li.product.subscribable? }
        end

        def finalize_with_create_subscription!
          finalize_without_create_subscription!
          create_subscription_if_eligible
        end


        def create_subscription_if_eligible
          return unless subscribable?
          return if repeat_order?
          self.subscription = ::Spree::Subscription.create!(ship_address_id: ship_address.id, user_id: user.id)
        end

      end
    end
  end
end
::Spree::Order.send(:include, SpreeSubscriptions::Extensions::Spree::Order)
