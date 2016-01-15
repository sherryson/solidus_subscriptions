require "spec_helper"

feature "Subscription", type: :request do
  include SubscriptionMacros

  before(:each) do
    user = create(:user)
    setup_subscription_for user
    sign_in_as! user
  end

  context "Pausing a subscription" do
    before(:each) do
      @my_account = MyAccount::Page.new
    end

    scenario "changes its state to pause" do
      subscription = @my_account.subscriptions.first

      subscription.pause

      expect(subscription.state).to eq('Paused')
      expect(subscription).to_not have_css(".pause-subscription")

    end
  end

  context "A paused subscription" do
    before(:each) do
      @subscription.pause

      @my_account = MyAccount::Page.new
    end

    scenario "can be resumed with today's date" do
      subscription = @my_account.subscriptions.first

      subscription.resume Date.today

      expect(subscription.state).to eq('Active')
    end

    scenario "can be set to be resumed on a specific date" do
      subscription = @my_account.subscriptions.first

      subscription.resume next_month

      expect(subscription.state).to eq('Paused')
      expect(subscription).to have_text("Will be resumed on #{next_month}")
    end
  end


  private

  def next_month
    Date.today + 1.month
  end

end
