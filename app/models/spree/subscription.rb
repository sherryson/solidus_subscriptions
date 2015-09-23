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

    has_many :subscription_skips, dependent: :destroy, inverse_of: :subscription
    alias_attribute :skips, :subscription_skips

    accepts_nested_attributes_for :ship_address
    accepts_nested_attributes_for :bill_address

    validates_presence_of :ship_address
    validates_presence_of :bill_address
    validates_presence_of :user

    after_save :reset_failure_count, if: :credit_card_id_changed?

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
          next if subscription.prepaid?
          subscription.next_shipment_date.to_date <= Date.today          
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
        skip_order_at.advance(calc_next_renewal_date)
      elsif last_order
        last_order.completed_at.advance(calc_next_renewal_date)
      end
    end

    def calc_next_renewal_date
      { weeks: interval }      
    end

    def active?
      self.state == 'active'
    end

    def cancelled?
      state == 'cancelled'
    end

    def paused?
      state == 'paused'
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

    def last_order_date
      orders.first.complete? ? orders.first.completed_at : orders.first.created_at
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
      # just keeping safe
      non_existing_attributes = Spree::SubscriptionAddress.dup.attribute_names - Spree::Address.attribute_names

      # use subscription's addresses for the new order and email
      created_order = orders.create!(
        user: last_order.user,
        repeat_order: true,
        bill_address: Spree::Address.new(bill_address.dup.attributes.except(*non_existing_attributes)),
        ship_address: Spree::Address.new(ship_address.dup.attributes.except(*non_existing_attributes)),
        channel: 'subscription'
      )
      created_order.update_column(:email, email) if email
      created_order
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
      skips.create(skip_at: next_shipment_date) if skip_order_at.nil?
    end

    def undo_skip_next_order
      skips.last.update_attribute(:undo_at, Time.now)
    end

    def skip_order_at
      skips.last.skip_at if skips.any? && skips.last.undo_at.nil?
    end

    def pause
      update_attributes(pause_at: Time.now, resume_at: nil, state: 'paused')
    end

    def resume
      update_attributes(pause_at: nil, resume_at: Time.now, state: 'active')
    end

    def completed_orders
      orders.complete
    end

    # fetch the last completed order shipment
    def shipment
      last_order.shipments.last
    end

    # fetch the last completed order shipping method
    def shipping_method
      shipment.shipping_method
    end

    def failed_last_renewal?
      !orders.first.complete?
    end

    def can_renew?
      interval && !cancelled? && !paused?
    end

    def add_new_credit_card(params)
      ::Spree::CreditCard.transaction do
        credit_card = user.credit_cards.create(params)
        update_column(:credit_card_id, credit_card.id)

        CardStore.store_card_for_user(user, credit_card, credit_card.verification_value)
      end
    end

    def subscription_log_for(order)
      ::SubscriptionLog.where(order_id: order.id).last
    end

    def as_json(options = { })
      super((options || { }).merge({
          :methods => [:next_shipment_date, :skip_order_at]
      }))
    end

  end
end
