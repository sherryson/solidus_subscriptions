module Spree
  module VariantExtensions

    delegate :subscribable?, to: :product
    
  end
end

::Spree::Variant.prepend Spree::VariantExtensions
