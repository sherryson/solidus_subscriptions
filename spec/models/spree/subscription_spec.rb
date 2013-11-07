require 'spec_helper'

describe Spree::Subscription do
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

  context "#prepaid" do
    before do
      create_completed_subscription_order
    end

    it "should know if it's been paid for in advance" do
      order.subscription.prepaid?.should be_false
    end

    it "should know if it has a prepaid balance remaining" do
      order.subscription.prepaid_balance_remaining?.should be_false
    end

    it "should be set to prepaid when a prepaid order is submitted" do
      create_completed_prepaid_subscription_order
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
