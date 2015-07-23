require 'spec_helper'

describe GenerateSubscriptionOrder do
  include OrderMacros
  include ProductMacros
  before do
    setup_subscribable_products
    setup_prepayable_subscription_variants
  end

  context "#call" do
    it 'should generate a new subscription order when called' do
      create_completed_subscription_order
      subscription = @order.subscription
      Spree::Order.complete.count.should == 1
      GenerateSubscriptionOrder.new(subscription).call
      Spree::Order.complete.count.should == 2
    end

    it "should not generate orders for prepaid subscriptions" do
      create_completed_prepaid_subscription_order
      create_completed_subscription_order
      Timecop.travel(2.months.from_now)
      Spree::Subscription.ready_for_next_order.count.should == 1
    end
  end

  context "prepaid" do
    it 'should reduce the remaining duration when processed' do
      create_completed_prepaid_subscription_order
      subscription = @order.subscription
      Spree::Order.complete.count.should == 1
      @order.subscription.duration.should == 6
      GenerateSubscriptionOrder.new(subscription).call
      Spree::Order.complete.count.should == 2
      @order.subscription.duration.should == 5
      @order.total.should be > 0
      @order.subscription.orders.first.total.to_f.should == 15.0
    end

    it 'should not process when the final installment has been fulfilled' do
      create_completed_prepaid_subscription_order
      subscription = @order.subscription
      Spree::Order.complete.count.should == 1
      @order.subscription.update_column(:duration, 2)
      GenerateSubscriptionOrder.new(subscription).call
      Spree::Order.complete.count.should == 2
      GenerateSubscriptionOrder.new(subscription).call.should be_false
    end
  end

end
