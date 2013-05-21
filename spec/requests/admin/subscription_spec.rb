require 'spec_helper'

describe 'Subscription' do
  before do
    user = create(:admin_user, email: "test@example.com")
    sign_in_as!(user)
    visit spree.admin_path
  end


  context "listing subscriptions" do
    it "should list all subscriptions" do
      click_link "Subscriptions"
    end

  end

end
