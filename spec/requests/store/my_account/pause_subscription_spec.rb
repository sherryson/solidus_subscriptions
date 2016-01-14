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
    scenario "changes its state to pause" do
      visit "/account"

      within a_given_subscription do
        click_link("Pause")
      end

      within a_given_subscription do
        expect(state_column).to have_text("Paused")
        expect(page).to_not have_css("a.pause-subscription")
      end
    end

    context "A paused subscription" do

      before(:each) do
        pause_the_subscription

        visit "/account"
      end

      scenario "has a 'resume at' function" do
        pending
        within a_given_subscription do
          expect(page).to have_text("Resume At")
          expect(page).to have_css("input#resume-at")
        end
      end

      scenario "can be resumed" do
        within a_given_subscription do
          click_button("Resume")
        end

        within a_given_subscription do
          expect(state_column).to have_text("Active")
        end
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
