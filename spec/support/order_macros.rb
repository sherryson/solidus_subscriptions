module OrderMacros
  include SubscriptionTransitions

  def create_completed_subscription_order(user = default_user)
    order_factory(user)
    @order.create_proposed_shipments
    @order.payments.create!({source: @card, payment_method: @gateway, amount: @order.total})

    transition_order_from_cart_to_payment!(@order)
    transition_order_from_payment_to_complete!(@order)

    ship_order(@order)
  end

  def order_factory(user)
    country_zone = create(:zone)
    @state = create(:state)
    @country = @state.country
    country_zone.members.create(:zoneable => @country)
    @shipping_method = create(:shipping_method)

    @order = FactoryGirl.create(:order, user: user, ship_address: FactoryGirl.create(:address), bill_address: FactoryGirl.create(:address))
    line_items = [
      FactoryGirl.create(:line_item, order: @order, variant: create(:subscribable_variant), interval: 2),
      FactoryGirl.create(:line_item, order: @order, variant: create(:subscribable_variant), interval: 4),
      FactoryGirl.create(:line_item, order: @order, variant: create(:variant))
    ]
    @gateway = Spree::Gateway::Bogus.create!({active: true, name: 'Credit Card'})
    @card = FactoryGirl.create(:credit_card)
  end

  def ship_order(order)
    shipment = order.shipments.first
    shipment.inventory_units.update_all state: 'on_hand'
    shipment.update_column('state', 'ready')
    shipment.reload.ship
  end

  def default_user
    user = Spree.user_class.new(email: "spree@example.com", password: 'dynamo1234')
    user.generate_spree_api_key!
    user
  end
end
