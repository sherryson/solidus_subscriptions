module Spree
  class Subscription < ActiveRecord::Base
    has_many :orders, order: 'created_at DESC'
    belongs_to :user
    attr_accessible :ship_address_id, :state, :user_id, :interval

    validates_presence_of :ship_address_id
    validates_presence_of :user_id
    
    class << self
      def active
        where(state: nil)
      end
      
      def ready_for_next_order
        subs = active.select do |sub|
          sub.last_order &&
            sub.last_order.completed_at < sub.interval.weeks.ago
        end

        where(id: subs.collect(&:id))
      end
    end

    def products
      orders.last.subscription_products
    end

    def last_shipment_date
      last_order.shipment.shipped_at
    end

    def next_shipment_date
      last_order.updated_at.advance(weeks: interval)
    end

    def cancelled?
      state == 'cancelled'
    end

    def cancel
      update_attribute(:state, 'cancelled')
    end

    def last_order
      @last_order ||= orders.complete.reorder("completed_at DESC").first
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
  end
end
