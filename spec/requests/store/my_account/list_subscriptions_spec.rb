require "spec_helper"

feature "Editing a subscription", type: :request do
  include SubscriptionMacros

  before(:each) do
    user = create(:user)
    setup_subscriptions_for user
    sign_in_as! user

    @list_subscriptions = MyAccount::ListSubscriptionsPage.new
  end

  scenario "list the user subscriptions" do
    subscriptions = @list_subscriptions.subscriptions

    expect(subscriptions).to have_selector("tbody > tr", 2)
  end

end
