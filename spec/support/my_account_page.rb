module MyAccount

  class Page
    include Capybara::DSL

    def initialize
        visit "/account"
    end

    def any_subscription
      Subscription.new("#content table.subscription-summary > tbody > tr:first-of-type")
    end
  end

  class Subscription
    include Capybara::DSL

    def initialize(subscription)
      @subscription = subscription
    end

    def pause
      find(@subscription).find(".pause-subscription").click
    end

    def resume(resume_on_date)
      find(@subscription).fill_in("subscription[resume_at]", with: resume_on_date)
      find(@subscription).find(".resume-subscription").click
    end

    def cancel
      find(@subscription).find(".cancel-subscription").click
    end

    def edit
      find(@subscription).find(".edit-subscription").click
      SubscriptionPage.new
    end

    def state
      find(@subscription).find("td:nth-of-type(5)").text
    end
  end

  class SubscriptionPage
    include Capybara::DSL

    def billing_address
      AddressForm.new("div#billing")
    end

    def shipping_address
      AddressForm.new("div#shipping")
    end

    def submit
      find("input.btn-success").click
    end
  end

  class AddressForm
    include Capybara::DSL

    def initialize(address)
      @address = address
    end

    def first_name
      find(@address).find_field("First Name")
    end

    def first_name=(new_first_name)
      first_name.set new_first_name
    end

    def last_name
      find(@address).find_field("Last Name")
    end

    def last_name=(new_last_name)
      last_name.set new_last_name
    end

    def street_address
      find(@address).find_field("Street Address")
    end

    def street_address=(new_street_address)
      street_address.set new_street_address
    end

    def street_address_2
      find(@address).find_field("Street Address (cont'd)")
    end

    def street_address_2=(new_street_address_2)
      street_address_2.set new_street_address_2
    end

    def city
      find(@address).find_field("City")
    end

    def city=(new_city)
      city.set new_city
    end

    def country
      find(@address).find_field("Country")
    end

    def country=(new_country)
      country.set new_country
    end

    def state
      find(@address).find_field("State")
    end

    def state=(new_state)
      state.set new_state
    end

    def zip_code
      find(@address).find_field("Zip")
    end

    def zip_code=(new_zip_code)
      zip_code.set new_zip_code
    end

    def phone
      find(@address).find_field("Phone")
    end

    def phone=(new_phone)
      phone.set new_phone
    end
  end
end
