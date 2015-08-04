require 'spec_helper'
include OrderMacros
include ProductMacros

module Spree
  describe Api::SubscriptionsController, type: :controller do
    render_views

    let(:current_api_user) do
      user = Spree.user_class.new(email: "spree@example.com", password: 'dynamo1234')
      user.generate_spree_api_key!
      user
    end

    before do
      stub_authentication!
      setup_subscribable_products
    end

    it "restricts access to subscriptions" do
      create_completed_subscription_order
      @subscription = Spree::Subscription.last
      api_get :show, id: @subscription.id
      expect(json_response[:id]).to be nil
    end

    it "should allow the owner of the subscription to access it" do
      create_completed_subscription_order
      @subscription = Spree::Subscription.last
      @subscription.user = current_api_user
      @subscription.save
      api_get :show, id: @subscription.id
      expect(json_response[:id]).to be @subscription.id
    end

  end
end
