module SpreeSubscriptions
  module Extensions
    module Spree
      module Order
        extend ActiveSupport::Concern

        included do
          alias_method_chain :finalize!, :create_subscription
          alias_method_chain :add_variant, :interval
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

        def add_variant_with_interval(variant, quantity, interval = nil, currency = nil)
          return add_variant_without_interval(variant, quantity, currency) if interval.nil?

          current_item = find_line_item_by_variant(variant)
          if current_item
            raise "Unsupported behaviour"
          else
            current_item = ::Spree::LineItem.new(:quantity => quantity, :interval => interval)

            current_item.variant = variant
            if currency
              current_item.currency = currency unless currency.nil?
              current_item.price    = variant.price_in(currency).amount
            else
              current_item.price    = variant.price
            end
            self.line_items << current_item
          end

          self.reload
          current_item
        end
      end
    end
  end
end

::Spree::Order.send(:include, SpreeSubscriptions::Extensions::Spree::Order)
