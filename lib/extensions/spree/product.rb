module SpreeSubscriptions
  module Extensions
    module Spree
      module Product

        def self.prepended(base)
          class << base
            prepend ClassMethods
          end
        end

        module ClassMethods
          def subscribable
            ids = ::Spree::Variant.with_frequency.map(&:product_id).uniq
            where('spree_products.id IN (?)', ids).select { |p| p.subscribable? }
          end

          def prepayable
            ids = ::Spree::Variant.with_duration.map(&:product_id).uniq
            where('spree_products.id IN (?)', ids).select { |p| p.subscribable? }
          end

        end

        def subscribable_option_values
          variants.collect(&:option_values).flatten.select do |ov|
           ov.name.to_i > 1 && ov.option_type.name == frequency_option_type
          end
        end

        def subscribable?
          subscribable_option_values.any?
        end

        def frequency_option_type
          ::Spree::OptionType.find_by_name('frequency').name
        end

        def duration_option_type
          ::Spree::OptionType.find_by_name('number_of_months').name
        end

        def subscribable_variants
          @subscribable_variants ||= variants.select do |v|
            frequencies = v.option_values.joins(:option_type).where('spree_option_types.name = ?', 'frequency')
            frequencies.select { |f| f.name.to_i > 0 }.any?
          end
        end

        def prepayable_variants
          @prepayable_variants ||= variants.select do |v|
            durations = v.option_values.joins(:option_type).where('spree_option_types.name = ?', 'number_of_months')
            durations.select { |f| f.name.to_i > 0 }.any?
          end
        end

      end
    end
  end
end

::Spree::Product.prepend SpreeSubscriptions::Extensions::Spree::Product
