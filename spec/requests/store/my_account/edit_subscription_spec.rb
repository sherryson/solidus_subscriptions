require "spec_helper"

feature "Editing a subscription", type: :request do
  include SubscriptionMacros

  before(:each) do
    user = create(:user)
    setup_subscription_for user
    sign_in_as! user

    my_account = MyAccount::Page.new
    @edit_subscription = my_account.any_subscription.edit
  end

  scenario "edit the interval and emails" do
    @edit_subscription.email = "updated@email.com"
    @edit_subscription.interval = "42"

    @edit_subscription.submit

    expect(@edit_subscription.email.value).to eq("updated@email.com")
    expect(@edit_subscription.interval.value).to eq("42")
  end
end
