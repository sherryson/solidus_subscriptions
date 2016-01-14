require "spec_helper"

feature "Subscription" do
  include OrderMacros
  include ProductMacros

  context "Pausing a subscriptions" do
    before(:each) do
      user = create(:user)
      setup_subscription_for user
      sign_up_with user.email, user.password
    end

    scenario "changes its state to pause" do
      visit "/account"

      given_a_subscription do
        click_link("Pause")
      end

      expect(state_column).to have_text("Paused")
    end
  end


  private

  def sign_up_with(email, password)
    visit "/login"
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Login"
  end

  def setup_subscription_for(user)
    setup_subscribable_products
    create_completed_subscription_order
    associate_subscription_to user
  end

  def associate_subscription_to(user)
    @subscription = Spree::Subscription.last
    @subscription.update_attribute(:user, user)
    @subscription.shipping_address.update_attribute(:user, user)
    @subscription.billing_address.update_attribute(:user, user)

    @order.update_attribute(:user, user)
  end

  def given_a_subscription
    within subscription_row do
      yield
    end
  end

  def subscription_row
    "div#content table.subscription-summary > tbody > tr:first-of-type"
  end

  def state_column
    find(subscription_row + " > td:nth-of-type(4)")
  end

end
