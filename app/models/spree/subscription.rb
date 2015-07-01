module Spree
  class Subscription < ActiveRecord::Base
    has_many :orders, -> { order 'updated_at desc' }
    has_many :subscription_items, dependent: :destroy, inverse_of: :subscription
    belongs_to :user
    belongs_to :credit_card

    belongs_to :bill_address, foreign_key: :bill_address_id, class_name: 'Spree::SubscriptionAddress'
    alias_attribute :billing_address, :bill_address

    belongs_to :ship_address, foreign_key: :ship_address_id, class_name: 'Spree::SubscriptionAddress'
    alias_attribute :shipping_address, :ship_address    

    accepts_nested_attributes_for :ship_address
    accepts_nested_attributes_for :bill_address

    validates_presence_of :ship_address_id
    validates_presence_of :bill_address_id
    validates_presence_of :user_id

    class << self
      def active
        where(state: 'active')
      end

      def paused
        where(state: 'paused')
      end

      def with_interval
        where('interval > 0')
      end

      def prepaid
        where('duration > 1')
      end

      def good_standing
        where('failure_count < 6')
      end

      def ready_for_next_order
        subscriptions = active.with_interval.good_standing.select do |subscription|
          last_order = subscription.last_order
          next unless last_order
          next unless subscription.skip_order_at <= subscription.next_shipment_date if subscription.skip_order_at
          last_order.completed_at.at_beginning_of_day < (subscription.interval * 4).weeks.ago
        end

        where(id: subscriptions.collect(&:id))
      end

    end

    def products
      last_order.subscription_products
    end

    def last_shipment_date
      last_order.completed_at if last_order
    end

    def next_shipment_date
      if skip_order_at
        skip_order_at.advance(weeks: interval * 4)
      elsif last_order
        last_order.completed_at.advance(weeks: interval * 4)
      end
    end

    def active?
      self.state == 'active'
    end

    def cancelled?
      state == 'cancelled'
    end

    def cancel
      update_attribute(:state, 'cancelled')
      update_attribute(:cancelled_at, Time.now)
    end

    alias_method :cancel!, :cancel

    def last_order
      orders.complete.reorder("completed_at desc").first
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
      orders.create!(
        user: last_order.user,
        email: last_order.email,
        repeat_order: true,
        bill_address: bill_address,
        ship_address: ship_address,
        channel: 'subscription'
      )
    end

    def prepaid?
      duration && duration > 0
    end

    def eligible_for_processing?
      active? && (!prepaid? || duration > 1)
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

    def remaining_shipments
      duration - 2
    end

    def skip_next_order
      update_column(:skip_order_at, next_shipment_date)      
    end

    def undo_skip_next_order
      update_column(:skip_order_at, nil)
    end

    def as_json(options = { })
      super((options || { }).merge({
          :methods => [:next_shipment_date]
      }))
    end

  end
end
