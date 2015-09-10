require 'spec_helper'

describe Spree::Subscription do
  include OrderMacros
  include ProductMacros

  before do
    setup_subscribable_products
  end

  it { should have_many(:orders) }
  it { should belong_to(:user) }
  it { should belong_to(:credit_card)}
  it { should respond_to(:resume_on)}

  context "#products" do
    it 'should return a collection of products' do
      create_completed_subscription_order
      @order.subscription.products.map(&:subscribable?).all?.should be true
    end
  end

  context "#credit_card" do
    before do
      create_completed_subscription_order
    end

    it "should be automatically associated with a credit card when the initial order is completed" do
      expect(@order.subscription.credit_card).not_to be_nil
    end
  end

  context "shipment dates" do
    before do
      Timecop.freeze
      create_completed_subscription_order
    end

    it "should return the shipment date of the last order" do
      @order.subscription.last_shipment_date.to_i.should == Time.now.to_i
    end

    it "should be able to calculate the date of the next shipment" do
      @order.subscription.next_shipment_date.to_i.should == 2.weeks.from_now.to_i
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
      @order.subscription.prepaid?.should be false
    end

    it "should know if it has a prepaid balance remaining" do
      @order.subscription.prepaid_balance_remaining?.should be false
    end

    it "should be set to prepaid when a prepaid order is submitted" do
      setup_prepayable_subscription_variants
      create_completed_prepaid_subscription_order
      @order.subscribable?.should be true
      @order.subscription.duration.should == 6
      @order.subscription.interval.should == 4
      @order.subscription.prepaid?.should be true
    end
  end

  describe "#cancelled?" do
    let(:subscription) { FactoryGirl.create(:subscription, state: subscription_state) }

    context "when the subscription has been cancelled" do
      let(:subscription_state) { 'cancelled' }

      it "returns true" do
        expect(subscription.cancelled?).to be true
      end
    end

    context "when the subscription has not been cancelled" do
      let(:subscription_state) { nil }

      it "returns false" do
        expect(subscription.cancelled?).to be false
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

  describe "#pause" do
    let(:subscription) { FactoryGirl.create(:subscription, state: nil) }
    it "pause the subscription" do
      expect {
        subscription.pause
      }.to change {
        subscription.state
      }.from(nil).to('paused')
    end
  end

  describe "#resume" do
    let(:subscription) { FactoryGirl.create(:subscription, state: 'paused') }
    it "resumes the subscription" do
      expect {
        subscription.resume
      }.to change {
        subscription.state
      }.from(nil).to('active')
    end
  end  
  

end
