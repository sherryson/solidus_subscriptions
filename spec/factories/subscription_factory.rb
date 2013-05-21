FactoryGirl.define do
  factory :subscription, :class => Spree::Subscription do
    state nil
    interval 2
    ship_address_id {
      FactoryGirl.create(:address).id
    }

    association(:user)
  end
end
