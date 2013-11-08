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
      Spree::Order.complete.count == 1
      GenerateSubscriptionOrder.new(subscription).call
      Spree::Order.complete.count == 2
    end
  end

  context "prepaid" do
    it 'should reduce the remaining duration when processed' do
      create_completed_prepaid_subscription_order
      subscription = @order.subscription
      Spree::Order.complete.count == 1
      @order.subscription.duration.should == 6
      GenerateSubscriptionOrder.new(subscription).call
      Spree::Order.complete.count == 2
      @order.subscription.duration.should == 5
    end
  end

end
