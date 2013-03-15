FactoryGirl.define do
  factory :customer_address, :class => Spree::Address do
    firstname 'Bryan'
    lastname 'Mahoney'
    address1 '439 Saint-Pierre'
    city 'Montreal'
    phone '01010101'
    zipcode 1111
    state_name 'Galaxy'
    country
  end
end
