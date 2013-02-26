FactoryGirl.define do
  factory :subscribable_variant, parent: :base_variant do
    product { |p| p.association(:subscribable_product)}
  end
  
end
