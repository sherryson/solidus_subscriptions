FactoryGirl.define do
  factory :subscription, :class => Spree::Subscription do
    state nil
    interval 2
    prepaid false  

    ship_address {
      FactoryGirl.create(:subscription_address)
    }
    bill_address {
      FactoryGirl.create(:subscription_address)
    }

    association(:user)
  end
end
