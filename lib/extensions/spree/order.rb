module SpreeSubscriptions
  module Extensions
    module Spree
      module Order
        extend ActiveSupport::Concern

        included do
          alias_method_chain :finalize!, :create_subscription
          alias_method_chain :add_variant, :interval

          belongs_to :subscription, class_name: 'Spree::Subscription'
          attr_accessible :subscription_id
        end

        def finalize_with_create_subscription!
          create_subscription_if_eligible
          finalize_without_create_subscription!
        end

        def create_subscription_if_eligible
          return unless subscribable?
          return if repeat_order?

          attrs = {
            ship_address_id: ship_address.id,
            user_id: user.id,
            interval: subscription_interval
          }

          self.create_subscription(attrs)
        end

        def subscribable?
          subscribable_option_values.any?
        end

        def subscription_interval
          subscribable_option_values.collect(&:name).max
        end

        def subscribable_option_values
          variants.collect(&:option_values).flatten.select do |ov|
           ov.name.to_i > 1 && ov.option_type.name == frequency_option_type
          end
        end

        def frequency_option_type
          ::Spree::OptionType.find_by_name('frequency').name
        end


        def has_subscription?
          subscription_id.present?
        end

        def subscription_products
          line_items.map { |li| li.variant.product }.select { |p| p.subscribable? }
        end


        def add_variant_with_interval(variant, quantity, *args)
          interval = args.shift if args.count > 1
          currency = args.first

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
