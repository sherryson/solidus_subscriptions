class CreateOptionTypeForFrequency < ActiveRecord::Migration
  def up
    return unless Spree::OptionType.find_by_name('frequency').nil?
    frequency = Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
    Spree::OptionValue.create!({ name: 2, presentation: 'Every 2 weeks', option_type: frequency }, without_protection: true)
    Spree::OptionValue.create!({ name: 4, presentation: 'Every 4 weeks', option_type: frequency }, without_protection: true)
  end

  def down
  end
end
