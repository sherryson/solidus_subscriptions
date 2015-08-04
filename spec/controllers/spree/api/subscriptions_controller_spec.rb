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

    it "can only view my subscriptions" do
      create_completed_subscription_order
      @subscription = Spree::Subscription.last
      api_get :show, id: @subscription.id
      expect(json_response[:id]).to be nil
    end


    # context "PUT 'update'" do
    #
    #   it "should let me update my subscription" do
    #     expect("test").to be false
    #   end
    #
    # end
  end
end
