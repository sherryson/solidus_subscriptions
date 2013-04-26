module Spree
  class Subscription < ActiveRecord::Base
    has_many :orders, order: 'created_at DESC'
    belongs_to :user
    attr_accessible :ship_address_id, :state, :user_id, :interval

    validates_presence_of :ship_address_id
    validates_presence_of :user_id

    def products
      orders.last.subscription_products
    end

    def last_order
      orders.last
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
  end
end
