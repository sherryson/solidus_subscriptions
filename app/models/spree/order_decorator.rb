module Spree
  module OrderExtensions

    def self.prepended(base)
      base.alias_method_chain :finalize!, :create_subscription
      base.belongs_to :subscription, class_name: 'Spree::Subscription'
      base.register_line_item_comparison_hook(:line_item_interval_match)
    end

    def finalize_with_create_subscription!
      create_subscription_if_eligible
      finalize_without_create_subscription!
    end

    def line_item_interval_match(line_item, options)
      return true unless options[:interval].present?
      line_item.interval == options[:interval]
    end

    def create_subscription_if_eligible
      begin
        items = subscribable_line_items.group_by { |item| item.interval }
        # pull user by email, this considers existing users opted for guest checkout
        user = User.find_by_email email
        items.keys.each do |interval|
          attrs = {
            user_id: user.id,
            email: email,
            state: 'active',
            interval: interval,
            prepaid_amount: subscription_prepaid_amount,
            credit_card_id: credit_card_id_if_available
          }
          subscription = create_subscription(attrs)

          # create subscription addresses
          subscription.create_ship_address!(ship_address.dup.attributes.merge({user_id: user.id}))
          subscription.create_bill_address!(bill_address.dup.attributes.merge({user_id: user.id}))

          # orders can have many subscriptions
          subscriptions << subscription

          # create subscription items
          items[interval].each do |line_item|
            # and skip those are not subscribable
            next unless line_item.product.subscribable?
            ::Spree::SubscriptionItem.create!(
              subscription: subscription,
              variant: line_item.variant,
              quantity: line_item.quantity,
              interval: interval
            )
          end
        end
      rescue => e
        # TODO: Hook into error reporting
        Rails.logger.error e.message
        Rails.logger.error e.backtrace
      end
    end

    def subscribable?
      false
    end

    def subscription_interval
      subscription.interval
    end

    def subscription_duration
    end

    def subscription_prepaid_amount
    end

    def has_subscription?
      subscription_id.present?
    end

    def subscription_products
      line_items.group_by { |item| item.interval }.reject{ |interval| interval.zero? }
    end

    def credit_card_id_if_available
      credit_cards.present? ? credit_cards.last.id : ''
    end

    def reset_failure_count_for_subscription
      if completed? && has_subscription?
        subscription.reset_failure_count
      end
    end

    def clear_skip_order_for_subscription
      if completed? && has_subscription?
        subscription.clear_skip_order
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

    def subscribable_line_items
      line_items.where('interval > 0')
    end

    # def create_store_credits_payment!
    #   add_store_credit_payments
    # end
  end
end

Spree::Order.prepend Spree::OrderExtensions

Spree::Order.state_machine.after_transition to: :complete, do: :reset_failure_count_for_subscription
Spree::Order.state_machine.after_transition to: :complete, do: :clear_skip_order_for_subscription
