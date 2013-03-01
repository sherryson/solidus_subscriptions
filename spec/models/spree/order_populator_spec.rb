require 'spec_helper'

describe Spree::OrderPopulator do

  describe '#populate' do

    context "with a variant hash including a quantity and interval" do

      let(:current_order)    { mock('current order') }
      let(:current_currency) { stub('current currency') }

      let(:variant)          { stub('variant') }

      subject { Spree::OrderPopulator.new(current_order, current_currency) }

      it "it attempts to add the variant to cart with the interval" do
        ::Spree::Variant.stub(:find).with('12345').and_return(variant)
        subject.stub(:check_stock_levels).and_return(true)

        input_hash = { variants: {
          '12345' => { quantity: '1', interval: '2' }
        }}

        current_order.should_receive(:add_variant).with(variant, 1, '2', current_currency)

        subject.populate(input_hash)
      end
    end
  end
end
