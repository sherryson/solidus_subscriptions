require 'spec_helper'

describe "Subscription" do
  context "as a user" do
    before do
      reset_spree_preferences do |config|
        config.default_country_id = create(:country).id
      end
      create(:payment_method)
      create(:free_shipping_method)
      @product1 = create(:subscribable_product, name: 'Giant Steps', available_on: '2011-01-06 18:21:13:')
      @product2 = create(:product, name: 'Bella Donavan', available_on: '2011-01-06 18:21:13:')
      @user = create(:user, email: "subscriber@bbc.com", password: "secret", password_confirmation: "secret")
    end
    context "after order completion with subscribable product" do
      before do
        add_to_cart("Giant Steps")
        complete_checkout_with_login("subscriber@bbc.com", "secret")
      end

      it "should find a subscription area in the user account page" do
        visit spree.account_path
        page.should have_content "My subscriptions"
      end
    end

  end
end
