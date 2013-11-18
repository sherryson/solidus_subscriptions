class CreatePrepaidOptionTypesAndValues < ActiveRecord::Migration
  def up
    return unless Spree::OptionType.find_by_name('number_of_months').nil?
    number_of_months = Spree::OptionType.create(name: 'number_of_months', presentation: 'Number of Months')
    Spree::OptionValue.create!({ name: 0, presentation: 'Not Prepaid', option_type: number_of_months }, without_protection: true)
    Spree::OptionValue.create!({ name: 3, presentation: '3 months', option_type: number_of_months }, without_protection: true)
    Spree::OptionValue.create!({ name: 6, presentation: '6 months', option_type: number_of_months }, without_protection: true)
    Spree::OptionValue.create!({ name: 9, presentation: '9 months', option_type: number_of_months }, without_protection: true)
    Spree::OptionValue.create!({ name: 12, presentation: '12 months', option_type: number_of_months }, without_protection: true)
  end

  def down
  end
end
