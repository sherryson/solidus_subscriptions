FactoryGirl.define do
  factory :subscribable_variant, parent: :base_variant do
    after(:create) do |variant|
      variant.product.subscribable = true
      variant.product.save
      build(:stock_item, variant: variant)
    end
  end

  factory :subscribable_product, parent: :base_product do
    variant = FactoryGirl.create(:subscribable_variant)
    after(:create) do |product|
      product.subscribable = true
      product.variants << variant
      product.save
    end
  end
end
