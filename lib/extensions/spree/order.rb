module SpreeSubscriptions
  module Extensions
    module Spree
      module Order

        def self.prepended(base)
          base.alias_method_chain :finalize!, :create_subscription

          base.belongs_to :subscription, class_name: 'Spree::Subscription'
          base.register_update_hook :reset_failure_count_for_subscription_orders          
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
              user_id: user.id,
              email: email,
              state: 'active',
              interval: subscription_interval,
              duration: subscription_duration,
              prepaid_amount: subscription_prepaid_amount,
              credit_card_id: credit_card_id_if_available
            }
            subscription = build_subscription(attrs)

            # create subscription addresses
            subscription.create_ship_address!(ship_address.dup.attributes.merge({user_id: user.id}))
            subscription.create_bill_address!(bill_address.dup.attributes.merge({user_id: user.id}))

            subscription.save
            # create subscription items
            self.line_items.each do |line_item|
              ::Spree::SubscriptionItem.create!(
                subscription: subscription,
                variant: line_item.variant,
                quantity: line_item.quantity
              )
            end
          rescue => e
            # TODO: Hook into error reporting
            Rails.logger.error e.message
            Rails.logger.error e.backtrace
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
          prepayable_option_values.present? ? prepayable_option_values.first.name.to_i : 0          
        end

        def subscription_prepaid_amount
          prepayable_option_values.present? ? total : 0
        end

        def subscribable_option_values
          line_items.collect(&:variant).collect(&:option_values).flatten.select do |ov|
            ov.name.to_i > 0 && ov.option_type.name == frequency_option_type
          end
        end

        def prepayable_option_values
          line_items.collect(&:variant).collect(&:option_values).flatten.select do |ov|
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

        def line_items_variants
          line_items.inject({}) do |hash, li|
            if li.variant.product.subscribable_variants.include? li.variant
              hash[li.variant.id] = li.quantity
            elsif li.variant.product.prepayable_variants.include? li.variant
              hash[li.variant.id] = li.quantity
            end

            hash
          end
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
          payments.create!(
            payment_method: payment_method,
            source: cc,
            amount: update_totals,
            state: 'checkout'
          )
        end
      end
    end
  end
end

::Spree::Order.prepend SpreeSubscriptions::Extensions::Spree::Order