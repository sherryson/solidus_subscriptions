module ProductMacros
  def setup_subscribable_products
    Spree::OptionType.create(name: 'number_of_months', presentation: 'Number of Months')
    frequency = Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
    two_weeks = Spree::OptionValue.create!({ name: 2, presentation: 'Every 2 weeks', option_type: frequency }, without_protection: true)

    @product = Spree::Product.create(name: 'Coffee Subscription', price: 15)
    @subscribable_variant = Spree::Variant.create({ product: @product, sku: 'subscribable', option_values: [two_weeks], on_hand: 100 }, without_protection: true)
  end
end
