require 'spec_helper'

describe Spree::Subscription do
  before do
    Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
  end

  let(:user) { stub_model(Spree::User, email: "spree@example.com") }
  let(:order) {
    FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address))
  }
  let(:line_items) {[
    FactoryGirl.create(:line_item),
    FactoryGirl.create(:line_item, variant: FactoryGirl.create(:subscribable_variant))
  ]}

  let(:gateway) do
    gateway = Spree::Gateway::Bogus.create!({environment: 'test', active: true, name: 'Credit Card'}, :without_protection => true)
    gateway.stub :source_required => true
    gateway
  end

  let(:card) do
    FactoryGirl.create(:credit_card)
  end


  it { should have_many(:orders) }
  it { should belong_to(:user) }
  it { should belong_to(:credit_card)}
  it { should respond_to(:resume_on)}

  context "#products" do
    it 'should return a collection of products' do
      order.line_items << line_items
      order.finalize!
      order.subscription.products.map(&:subscribable?).all?.should be_true 
    end
  end

  context "#credit_card" do
    before do
      create_completed_subscription_order
    end

    it "should be automatically associated with a credit card when the initial order is completed" do
      expect(order.subscription.credit_card).not_to be_nil
    end
  end

  context "shipment dates" do
    before do
      Timecop.freeze
      create_completed_subscription_order
    end

    it "should return the shipment date of the last order" do
      order.subscription.last_shipment_date.to_i.should == Time.now.to_i
    end

    it "should be able to calculate the date of the next shipment" do
      order.subscription.next_shipment_date.to_i.should == 2.weeks.from_now.to_i
    end

    after do
      Timecop.return
    end
  end

  describe "#cancelled?" do
    let(:subscription) { FactoryGirl.create(:subscription, state: subscription_state) }

    context "when the subscription has been cancelled" do
      let(:subscription_state) { 'cancelled' }

      it "returns true" do
        expect(subscription.cancelled?).to be_true
      end
    end

    context "when the subscription has not been cancelled" do
      let(:subscription_state) { nil }

      it "returns false" do
        expect(subscription.cancelled?).to be_false
      end
    end
  end

  describe "#cancel!" do
    let(:subscription) { FactoryGirl.create(:subscription, state: nil) }

    it "cancels the subscription" do
      expect {
        subscription.cancel!
      }.to change {
        subscription.state
      }.from(nil).to('cancelled')
    end
  end

  def create_completed_subscription_order
    Factory(:shipping_method)
    order.line_items << line_items
    order.shipping_method = Spree::ShippingMethod.first
    order.create_shipment!
    order.payments.create!({source: card, payment_method: gateway, amount: order.total}, without_protection: true)
    order.finalize!
    order.state = 'complete'
    order.shipment.state = 'ready'
    order.shipment.ship!
    order.update_column(:payment_state, 'paid')
  end
end
