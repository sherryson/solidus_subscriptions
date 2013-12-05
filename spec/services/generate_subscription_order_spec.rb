require 'spec_helper'

describe GenerateSubscriptionOrder do
  before do
    frequency = Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
    two_weeks = Spree::OptionValue.create!({ name: 2, presentation: 'Every 2 weeks', option_type: frequency }, without_protection: true)

    product = Spree::Product.create(name: 'Coffee Subscription', price: 15)
    @subscribable_variant = Spree::Variant.create({ product: product, option_values: [two_weeks], on_hand: 100 }, without_protection: true)
  end

  let(:user) { stub_model(Spree::User, email: "spree@example.com") }
  let(:order) {
    FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address), bill_address: FactoryGirl.create(:address))
  }
  let(:line_items) {[
    FactoryGirl.create(:line_item),
    FactoryGirl.create(:line_item, variant: @subscribable_variant)
  ]}

  let(:gateway) do
    gateway = Spree::Gateway::Bogus.create!({environment: 'test', active: true, name: 'Credit Card'}, without_protection: true)
    gateway.stub :source_required => true
    gateway
  end

  let(:card) do
    FactoryGirl.create(:credit_card)
  end

  context "#call" do
    it 'should generate a new subscription order when called' do
      create_completed_subscription_order
      subscription = order.subscription
      Spree::Order.complete.count == 1
      GenerateSubscriptionOrder.new(subscription).call
      Spree::Order.complete.count == 2
    end
  end

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
