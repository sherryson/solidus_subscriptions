module Spree
  module VariantExtensions

    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end

    def frequency
      option_values.of_option_type('frequency').first
    end

    def duration
      option_values.of_option_type('number_of_months').first
    end

    module ClassMethods
      def with_duration(*option_values)

        relation = joins(:option_values => :option_type).where('spree_option_types.name' => 'number_of_months' )

        option_values_conditions = option_values.each do |option_value|
          option_value_conditions = case option_value
          when OptionValue then { "spree_option_values.name" => option_value.name }
          when String      then { "spree_option_values.name" => option_value }
          else                  { "spree_option_values.id"   => option_value }
          end
          relation = relation.where(option_value_conditions)
        end

        relation
      end

      def with_frequency(*option_values)

        relation = joins(:option_values => :option_type).where('spree_option_types.name' => 'frequency' )

        option_values_conditions = option_values.each do |option_value|
          option_value_conditions = case option_value
          when OptionValue then { "spree_option_values.name" => option_value.name }
          when String      then { "spree_option_values.name" => option_value }
          else                  { "spree_option_values.id"   => option_value }
          end
          relation = relation.where(option_value_conditions)
        end

        relation
      end
    end
  end
end

::Spree::Variant.prepend Spree::VariantExtensions
