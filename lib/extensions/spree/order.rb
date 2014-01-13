module SpreeSubscriptions
  module Extensions
    module Spree
      module Order
        extend ActiveSupport::Concern

        included do
          alias_method_chain :finalize!, :create_subscription

          belongs_to :subscription, class_name: 'Spree::Subscription'
          attr_accessible :subscription_id
          register_update_hook :reset_failure_count_for_subscription_orders
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
              duration: subscription_duration,
              prepaid_amount: subscription_prepaid_amount,
              credit_card_id: credit_card_id_if_available
            }

            self.create_subscription(attrs)
          rescue => e
            # TODO: Hook into error reporting
          end
        end

        def subscribable?
          subscribable_option_values.any? || prepayable_option_values.any?
        end

        def will_create_prepaid_subscription?
          !repeat_order? && prepayable_option_values.any?
        end

        def subscription_interval
          subscribable_option_values.any? ? subscribable_option_values.collect(&:name).max : 4
        end

        def subscription_duration
          prepayable_option_values.present? ? prepayable_option_values.first.name : 0
        end

        def subscription_prepaid_amount
          prepayable_option_values.present? ? total : 0
        end

        def subscribable_option_values
          variants.collect(&:option_values).flatten.select do |ov|
           ov.name.to_i > 0 && ov.option_type.name == frequency_option_type
          end
        end

        def prepayable_option_values
          variants.collect(&:option_values).flatten.select do |ov|
           ov.name.to_i > 0 && ov.option_type.name == prepaid_option_type
          end
        end

        def frequency_option_type
          ::Spree::OptionType.find_by_name('frequency').name
        end

        def prepaid_option_type
          ::Spree::OptionType.find_by_name('number_of_months').name
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

        def reset_failure_count_for_subscription_orders
          if completed? && has_subscription?
            subscription.reset_failure_count
          end
        end

        def payment_method
          payments.last.payment_method
        end

        def create_payment!(payment_method, cc)
          payments.create!({
            payment_method: payment_method,
            source: cc,
            amount: update_totals,
            state: 'checkout'
          }, without_protection: true)
        end
      end
    end
  end
end

::Spree::Order.send(:include, SpreeSubscriptions::Extensions::Spree::Order)
