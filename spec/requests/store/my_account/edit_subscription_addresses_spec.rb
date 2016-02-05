require "spec_helper"

feature "Editing a subscription", type: :request do
  include SubscriptionMacros

  before(:each) do
    user = create(:user)
    setup_subscriptions_for user
    sign_in_as! user

    my_account = MyAccount::Page.new
    @edit_subscription = my_account.any_subscription.edit
  end

  context "Subscriptions Addresses" do
    scenario "edit the billing address" do
      update_and_validate_address @edit_subscription.billing_address
    end

    scenario "edit the shipping address" do
      update_and_validate_address @edit_subscription.shipping_address
    end

    def update_and_validate_address(address)
      address.first_name = "Updated FirstName"
      address.last_name = "Updated LastName"
      address.street_address = "Updated Street"
      address.street_address_2 = "Updated Apartment"
      address.city = "Updated City"
      address.zip_code = "12345"
      address.phone = "999-999-9999"

      @edit_subscription.submit

      expect(address.first_name.value).to eq("Updated FirstName")
      expect(address.last_name.value).to eq("Updated LastName")
      expect(address.street_address.value).to eq("Updated Street")
      expect(address.street_address_2.value).to eq("Updated Apartment")
      expect(address.city.value).to eq("Updated City")
      expect(address.zip_code.value).to eq("12345")
      expect(address.phone.value).to eq("999-999-9999")
    end
  end

end
