FactoryGirl.define do
  factory :subscribable_product, parent: :simple_product do
    subscribable true
  end
end
