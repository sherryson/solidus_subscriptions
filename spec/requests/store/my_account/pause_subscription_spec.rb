require "spec_helper"

feature "Subscription" do
  include OrderMacros
  include ProductMacros

  before(:each) do
    user = create(:user)
    setup_subscription_for user
    sign_up_with user.email, user.password
  end

  context "Pausing a subscription" do

    before(:each) do
      visit "/account"
    end

    scenario "changes its state to pause" do
      within a_given_subscription do
        find(".pause-subscription").click
      end

      within a_given_subscription do
        expect(state_column).to have_text("Paused")
        expect(page).to_not have_css(".pause-subscription")
      end
    end
  end

  context "A paused subscription" do

    before(:each) do
      pause_the_subscription
      visit "/account"
    end

    scenario "can be resumed with today's date" do
      within a_given_subscription do
        fill_in "subscription[resume_at]", with: Date.today
        click_button("Resume")
      end

      within a_given_subscription do
        expect(state_column).to have_text("Active")
      end
    end

    scenario "can be set to be resumed on a specific date" do
      resume_at = Date.today + 1.month

      within a_given_subscription do
        fill_in "subscription[resume_at]", with: resume_at
        click_button("Resume")
      end

      within a_given_subscription do
        expect(state_column).to have_text("Paused")
        expect(page).to have_text("Will be resumed on #{resume_at}")
      end
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

  def a_given_subscription
    "div#content table.subscription-summary > tbody > tr:first-of-type"
  end

  def state_column
    find("td:nth-of-type(4)")
  end

  def pause_the_subscription
    @subscription.pause
  end

end
