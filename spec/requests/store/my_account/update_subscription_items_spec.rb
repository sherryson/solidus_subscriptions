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

  scenario "removing an item from the subscription" do
    line_item = @edit_subscription.any_line_item

    line_item.delete

    expect(@edit_subscription).to_not have_css(line_items)
  end

  def line_items
    "#line-items > tbody > tr"
  end
end
