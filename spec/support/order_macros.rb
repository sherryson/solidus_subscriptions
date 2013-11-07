module OrderMacros
  def create_completed_subscription_order
    country_zone = create(:zone, :name => 'CountryZone')
    @state = create(:state)
    @country = @state.country
    country_zone.members.create(:zoneable => @country)
    @shipping_method = create(:shipping_method, :zone => country_zone)
    order.line_items << line_items
    order.shipping_method = Spree::ShippingMethod.first
    order.create_shipment!
    order.finalize!
    order.reload
    order.payments.create!({source: card, payment_method: gateway, amount: order.total, state: 'completed'}, without_protection: true)
    order.state = 'complete'
    order.shipment.state = 'ready'
    order.shipment.ship!
    order.shipment_state = 'shipped'
    order.payment_state = 'paid'
    order.save
  end
end
