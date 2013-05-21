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


  it { should have_many(:orders) }
  it { should belong_to(:user) }

  context "#products" do
    it 'should return a collection of products' do
      order.line_items << line_items
      order.finalize!
      order.subscription.products.map(&:subscribable?).all?.should be_true 
    end
  end

  context "shipment dates" do
    before do
      order.line_items << line_items
      order.stub :shipping_method => mock_model(Spree::ShippingMethod, :create_adjustment => true, :adjustment_label => "Shipping")
      order.create_shipment!
      order.stub(:paid? => true, :complete? => true)
      order.finalize!
      order.shipment.shipping_method = order.shipping_method
      order.shipment.ship!
    end

    it "should return the shipment date of the last order" do
      order.subscription.last_shipment_date.to_i.should == Time.now.to_i
    end

    it "should be able to calculate the date of the next shipment" do
      order.subscription.next_shipment_date.to_i.should == 2.weeks.from_now.to_i
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
end
