require 'spec_helper'

describe GenerateSubscriptionOrder do
  include OrderMacros
  include ProductMacros
  before do
    setup_subscribable_products
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


end
