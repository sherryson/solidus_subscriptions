module OrderMacros

  def create_completed_prepaid_subscription_order
    order_factory
    @order.line_items << FactoryGirl.create(:line_item, variant: @prepaid_variant)
    @order.shipping_method = Spree::ShippingMethod.first
    @order.create_shipment!
    @order.reload
    @order.payments.create!({source: @card, payment_method: @gateway, amount: @order.total, state: 'completed'}, without_protection: true)
    @order.state = 'complete'
    @order.shipment.state = 'ready'
    @order.shipment.ship!
    @order.shipment_state = 'shipped'
    @order.payment_state = 'paid'
    @order.finalize!
    @order.save
  end

  def create_completed_subscription_order
    order_factory
    @order.line_items << @line_items
    @order.shipping_method = Spree::ShippingMethod.first
    @order.create_shipment!
    @order.reload
    @order.payments.create!({source: @card, payment_method: @gateway, amount: @order.total, state: 'completed'}, without_protection: true)
    @order.state = 'complete'
    @order.shipment.state = 'ready'
    @order.shipment.ship!
    @order.shipment_state = 'shipped'
    @order.payment_state = 'paid'
    @order.finalize!
    @order.save
  end

  def order_factory
    country_zone = create(:zone)
    @state = create(:state)
    @country = @state.country
    country_zone.members.create(:zoneable => @country)
    @shipping_method = create(:shipping_method, :zone => country_zone)

    @user = stub_model(Spree::User, email: "spree@example.com")
    @order = FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address))

    @line_items = [
      FactoryGirl.create(:line_item),
      FactoryGirl.create(:line_item, variant: @subscribable_variant)
    ]

    @gateway = Spree::Gateway::Bogus.create!({environment: 'test', active: true, name: 'Credit Card'}, without_protection: true)
    @card = FactoryGirl.create(:credit_card)
  end
end
