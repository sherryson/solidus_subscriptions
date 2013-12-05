module SpreeSubscriptions
  module Extensions
    module Spree
      module Order
        extend ActiveSupport::Concern

        included do
          alias_method_chain :finalize!, :create_subscription

          belongs_to :subscription, class_name: 'Spree::Subscription'
          attr_accessible :subscription_id
        end

        def finalize_with_create_subscription!
          create_subscription_if_eligible
          finalize_without_create_subscription!
        end

        def create_subscription_if_eligible
          begin
            return unless subscribable?
            return if repeat_order?

            attrs = {
              ship_address_id: ship_address.id,
              bill_address_id: bill_address.id,
              user_id: user.id,
              state: 'active',
              interval: subscription_interval,
              credit_card_id: credit_card_id_if_available
            }

            self.create_subscription(attrs)
          rescue => e
            # TODO: Hook into error reporting
          end
        end

        def subscribable?
          subscribable_option_values.any?
        end

        def subscription_interval
          subscribable_option_values.collect(&:name).max
        end

        def subscribable_option_values
          variants.collect(&:option_values).flatten.select do |ov|
           ov.name.to_i > 0 && ov.option_type.name == frequency_option_type
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

        def credit_card_id_if_available
          credit_cards.present? ? credit_cards.last.id : ''
        end
      end
    end
  end
end

::Spree::Order.send(:include, SpreeSubscriptions::Extensions::Spree::Order)
