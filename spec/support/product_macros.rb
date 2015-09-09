module ProductMacros
  def setup_subscribable_products
    Spree::Product.delete_all
    Spree::OptionType.delete_all
    Spree::OptionValue.delete_all
    Spree::OptionType.create!(name: 'number_of_months', presentation: 'Number of Months')
    frequency = Spree::OptionType.create!(name: 'frequency', presentation: 'frequency')
    two_weeks = Spree::OptionValue.create!({ name: 2, presentation: 'Every 2 weeks', option_type: frequency })

    # required when creating stock items
    Spree::StockLocation.find_or_create_by(name: 'default')

    @product = Spree::Product.create(name: 'Coffee Subscription', price: 15, shipping_category_id: 1)
    @subscribable_variant = Spree::Variant.create!({ product: @product, sku: "subscribable - #{Spree::Variant.count}", option_values: [two_weeks], stock_items_count: 100 })
    @subscribable_variant.stock_items.first.adjust_count_on_hand(100)
  end

  def setup_prepayable_subscription_variants
    duration = Spree::OptionType.first_or_create!(name: 'number_of_months', presentation: 'Number of Months')
    six_months = Spree::OptionValue.create!({ name: 6, presentation: '6 months', option_type: duration })

    Spree::StockLocation.find_or_create_by(name: 'default')

    @prepaid_product = Spree::Product.create!(name: 'Prepaid Coffee Subscription', price: 200, shipping_category_id: 1)
    @prepaid_variant = Spree::Variant.create!({ product: @product, sku: "subscribable - #{Spree::Variant.count}", option_values: [six_months], stock_items_count: 100 })
    @prepaid_variant.stock_items.first.adjust_count_on_hand(100)
  end

end
