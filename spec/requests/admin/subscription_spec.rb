require 'spec_helper'

feature 'Subscription' do
  stub_authorization!

  context "listing subscriptions" do
    scenario "should list all subscriptions" do
      visit spree.admin_path
      click_link "Subscriptions"
    end
  end

end
