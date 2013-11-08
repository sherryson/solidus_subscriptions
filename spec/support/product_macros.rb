module ProductMacros
  def setup_subscribable_products
    Spree::OptionType.create(name: 'number_of_months', presentation: 'Number of Months')
    frequency = Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
    two_weeks = Spree::OptionValue.create!({ name: 2, presentation: 'Every 2 weeks', option_type: frequency }, without_protection: true)

    @product = Spree::Product.create(name: 'Coffee Subscription', price: 15)
    @subscribable_variant = Spree::Variant.create({ product: @product, sku: 'subscribable', option_values: [two_weeks], on_hand: 100 }, without_protection: true)
  end

  def setup_prepayable_subscription_variants
    duration = Spree::OptionType.create(name: 'number_of_months', presentation: 'Number of Months')
    six_months = Spree::OptionValue.create!({ name: 6, presentation: '6 months', option_type: duration }, without_protection: true)

    @prepaid_product = Spree::Product.create(name: 'Prepaid Coffee Subscription', price: 200)
    @prepaid_variant = Spree::Variant.create({ product: @product, sku: 'subscribable', option_values: [six_months], on_hand: 100 }, without_protection: true)
  end

end
