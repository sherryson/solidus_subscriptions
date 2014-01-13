module Spree
  class Subscription < ActiveRecord::Base
    has_many :orders, order: 'completed_at DESC'
    belongs_to :user
    belongs_to :credit_card
    attr_accessible :ship_address_id, :state, :user_id, :interval, :credit_card_id, :resume_on, :duration, :prepaid_amount, :bill_address_id

    validates_presence_of :ship_address_id
    validates_presence_of :bill_address_id
    validates_presence_of :user_id

    class << self
      def active
        where(state: 'active')
      end

      def ready_for_next_order
        subs = active.select do |sub|
          sub.last_order &&
            !sub.prepaid? &&
            sub.last_order.completed_at < sub.interval.weeks.ago
        end

        where(id: subs.collect(&:id))
      end

      def prepaid
        where('duration > 1')
      end

    end

    def products
      last_order.subscription_products
    end

    def last_shipment_date
      last_order.completed_at if last_order
    end

    def next_shipment_date
      last_order.completed_at.advance(weeks: interval) if last_order
    end

    def cancelled?
      state == 'cancelled'
    end

    def cancel
      update_attribute(:state, 'cancelled')
    end
    alias_method :cancel!, :cancel

    def last_order
      orders.complete.where(payment_state: 'paid').reorder("completed_at DESC").first
    end

    def last_order_credit_card
      last_order.payments.where('amount > 0').where(state: 'completed').last.source
    end

    def next_order
      next_order = NullObject.new

      next_order.class_eval do
        def created_at
          '???'
        end
      end

      next_order
    end

    def create_next_order!
      orders.create!({
        user: last_order.user,
        email: last_order.email,
        repeat_order: true,

        bill_address: bill_address,
        ship_address: ship_address

      }, without_protection: true)
    end

    def ship_address
      ::Spree::Address.find(ship_address_id) || last_order.ship_address
    end

    def bill_address
      ::Spree::Address.find(bill_address_id) || last_order.bill_address
    end

    def prepaid?
      duration && duration > 0
    end

    def prepaid_balance_remaining?
      prepaid_amount > 0
    end

    def retry_count
      5 - failure_count
    end

    def increment_failure_count
      update_column(:failure_count, failure_count + 1)
    end

    def reset_failure_count
      update_column(:failure_count, 0)
    end

    def decrement_prepaid_duration!
      return unless prepaid?
      update_column(:duration, duration-1)
    end
  end
end
