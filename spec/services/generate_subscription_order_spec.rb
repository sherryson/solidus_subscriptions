require 'spec_helper'

describe GenerateSubscriptionOrder do
  include OrderMacros
  include ProductMacros
  before do
    setup_subscribable_products
  end

  let(:user) { stub_model(Spree::User, email: "spree@example.com") }
  let(:order) {
    FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address))
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


end
