class SubscriptionSerializer < ActiveModel::Serializer
  extend Spree::Api::ApiHelpers
  cached
  delegate :cache_key, to: :object

  attributes :id, :interval, :state, :next_shipment_date, :skip_order_at, :email, :can_skip
  attributes :ship_address, :bill_address
  attributes :credit_card, :last_order

  has_many :subscription_items, serializer: SubscriptionItemSerializer
  has_many :skips, serializer: SubscriptionSkipSerializer

  def last_order
    order = object.orders.complete.reorder('completed_at desc').first
    {
      number: order.number,
      name: order.name,
      token: order.guest_token,
      line_items: order.line_items.map {|line| { quantity: line.quantity, name: line.variant.product.name, options_text: line.variant.options_text }},
      shipping_address: order.shipping_address,
      billing_address: order.billing_address
    }
  end
end