module MyAccount

  class Page
    include Capybara::DSL

    def initialize
        visit "/account"
    end

    def any_subscription
      Subscription.new("#content table.subscriptions-summary > tbody > tr:first-of-type")
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

    def element
      find(@subscription)
    end
  end

  class SubscriptionPage
    include Capybara::DSL

    def interval
      find_field("Frequency")
    end

    def interval=(new_interval)
      interval.set new_interval
    end

    def email
      find_field("Email")
    end

    def email=(new_email)
      email.set new_email
    end

    def add_variant_section
      find("div#add-line-item")
    end

    def select_new_variant_to_add(variant_id)
       add_variant_section.find("input[type = 'text']").set variant_id
    end

    def add_new_variant
      add_variant_section.find("input[type = 'submit']").click
    end

    def billing_address
      AddressForm.new("div#billing")
    end

    def shipping_address
      AddressForm.new("div#shipping")
    end

    def any_line_item
      LineItem.new("#line-items table > tbody > tr:first-of-type")
    end

    def submit
      find("input.btn-success").click
    end

    def payment_details
      find("#payment-info a.payment-details").click
      PaymentPage.new
    end
  end

  class LineItem
    include Capybara::DSL

    def initialize(line_item)
      @line_item = line_item
    end

    def delete
      find(@line_item).find(".delete-subscription-item").click
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

  class PaymentPage
    include Capybara::DSL

    def current_payment_info
      find("#current-payment-info")
    end

    def new_payment_method
      find("form div.card_form:first-of-type")
    end

    def number
      new_payment_method.find("input.card_number")
    end

    def number=(new_number)
      number.set new_number
    end

    def name
      new_payment_method.find("input.card_name")
    end

    def name=(new_name)
      name.set new_name
    end

    def expiry
      new_payment_method.find("input.card_expiry")
    end

    def expiry=(new_expiry)
      expiry.set new_expiry
    end

    def code
      new_payment_method.find("input.card_code")
    end

    def code=(new_code)
      code.set new_code
    end

    def submit
      find("#payment-info > form > input[type = 'submit']").click
    end
  end

  class ListSubscriptionsPage
    include Capybara::DSL

    def initialize
      visit "/subscriptions"
    end

    def subscriptions
      find("table.subscriptions-summary")
    end
  end
end
