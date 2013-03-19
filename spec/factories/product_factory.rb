FactoryGirl.define do

  factory :subscribable_variant, parent: :base_variant do
    frequency = Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
    two_weeks = Spree::OptionValue.create!({ name: 2, presentation: 'Every 2 weeks', option_type: frequency }, without_protection: true)
    on_hand 100
    after_create { |variant| variant.option_values << two_weeks }
  end

  factory :subscribable_product, parent: :simple_product do
    variant   = FactoryGirl.create(:subscribable_variant)
    after_create { |product| product.variants << variant }
  end


end
