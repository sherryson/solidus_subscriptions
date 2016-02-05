require "spec_helper"

feature "Subscription", type: :request do
  include SubscriptionMacros

  before(:each) do
    user = create(:user)
    setup_subscriptions_for user
    sign_in_as! user
  end

  context "Cancelling a subscription" do
    before(:each) do
      @my_account = MyAccount::Page.new
    end

    scenario "can be cancelled" do
      subscription = @my_account.any_subscription

      subscription.cancel

      expect(subscription.state).to eq('Cancelled')
      expect(subscription).to satisfy { |s| s.element.has_no_css? ".pause-subscription" }
      expect(subscription).to satisfy { |s| s.element.has_no_css? ".cancel-subscription" }
    end
  end

end
