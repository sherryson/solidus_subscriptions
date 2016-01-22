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

  scenario "removing an item" do
    line_item = @edit_subscription.any_line_item

    line_item.delete

    expect(@edit_subscription).to_not have_css(line_items)
  end

  scenario "adding an item" do
    a_new_variant = create(:subscribable_variant, sku: "SKU-42")
    @edit_subscription.find("div#add-line-item input[type = 'text']").set a_new_variant.id

    @edit_subscription.find("div#add-line-item input[type = 'submit']").click

    expect(find("#line-items table > tbody > tr:nth-of-type(2) > td:first-of-type")).to have_text("SKU-42")
  end

  def line_items
    "#line-items table > tbody > tr"
  end
end
