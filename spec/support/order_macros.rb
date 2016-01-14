module OrderMacros
  include SubscriptionTransitions

  def create_completed_prepaid_subscription_order
    order_factory
    @order.line_items << FactoryGirl.create(:line_item, variant: @prepaid_variant, interval: 2)
    @order.create_proposed_shipments
    @order.payments.create!({source: @card, payment_method: @gateway, amount: @order.total})

    transition_order_from_cart_to_payment!(@order)
    transition_order_from_payment_to_complete!(@order)

    ship_order(@order)
  end

  def create_completed_subscription_order
    order_factory
    @order.line_items << @line_items
    @order.create_proposed_shipments
    @order.payments.create!({source: @card, payment_method: @gateway, amount: @order.total})

    transition_order_from_cart_to_payment!(@order)
    transition_order_from_payment_to_complete!(@order)

    ship_order(@order)
  end

  def order_factory
    country_zone = create(:zone)
    @state = create(:state)
    @country = @state.country
    country_zone.members.create(:zoneable => @country)
    @shipping_method = create(:shipping_method)

    @user = double(Spree::User, email: "spree@example.com")
    @order = FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address), bill_address: FactoryGirl.create(:address))
    @line_items = [
      FactoryGirl.create(:line_item, variant: create(:subscribable_variant), interval: 2),
      FactoryGirl.create(:line_item, variant: create(:subscribable_variant), interval: 4),
      FactoryGirl.create(:line_item, variant: create(:variant))
    ]
    @gateway = Spree::Gateway::Bogus.create!({environment: 'test', active: true, name: 'Credit Card'})
    @card = FactoryGirl.create(:credit_card)
  end

  def ship_order(order)
    shipment = order.shipments.first
    shipment.state = 'ready'
    shipment.ship!
  end
end
