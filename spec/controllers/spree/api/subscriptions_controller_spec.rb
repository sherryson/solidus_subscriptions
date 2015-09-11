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

      create_completed_subscription_order
      @subscription = Spree::Subscription.last
      @subscription.update_column(:user_id, current_api_user.id)
    end

    it "restricts access to subscriptions" do
      @subscription.update_column(:user_id, 999)
      api_get :show, id: @subscription.id
      expect(json_response[:id]).to be nil
    end

    it "should allow the owner of the subscription to access it" do
      api_get :show, id: @subscription.id
      expect(json_response[:id]).to be @subscription.id
    end

    context "skipping" do
      it "should skip next order" do
        @subscription.next_shipment_date.to_date.should == 2.weeks.from_now.to_date

        api_get :skip_next_order, id: @subscription.id
        @subscription.next_shipment_date.to_date.should == 4.weeks.from_now.to_date
      end

      it "should be able to undo a skip next order" do
        @subscription.skip_next_order
        @subscription.next_shipment_date.to_date.should == 4.weeks.from_now.to_date

        api_get :undo_skip_next_order, id: @subscription.id
        @subscription.next_shipment_date.to_date.should == 2.weeks.from_now.to_date
      end
    end

    it "should be able to cancel a subscription" do
      api_put :cancel, id: @subscription.id
      @subscription.reload

      expect(@subscription.state).to eq 'cancelled'
      expect(@subscription.can_renew?).to be false
    end

    it "should be able to pause a subscription" do
      api_put :pause, id: @subscription.id
      @subscription.reload

      expect(@subscription.state).to eq 'paused'
      expect(@subscription.can_renew?).to be false
    end

    it "should be able to resume after pausing" do
      @subscription.pause
      expect(@subscription.state).to eq 'paused'

      api_put :resume, id: @subscription.id
      @subscription.reload

      expect(@subscription.state).to eq 'active'
      expect(@subscription.can_renew?).to be true
    end
  end
end
