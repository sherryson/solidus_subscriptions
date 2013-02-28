require 'spec_helper'

describe Spree::LineItem do

  let(:variant) { mock_model(Spree::Variant, :count_on_hand => 95, :price => 9.99) }
  let(:line_item) { Spree::LineItem.new(:quantity => 5) }
  let(:order) do
    shipments = mock(:shipments, :reduce => 0)
    mock_model(Spree::Order, :line_items => [line_item],
                             :inventory_units => [],
                             :shipments => shipments,
                             :completed? => true,
                             :update! => true)
  end

  before do
    line_item.stub(:order => order, :variant => variant, :new_record? => false)
    variant.stub(:currency => "USD")
    Spree::Config.set :allow_backorders => true
  end
  
  it 'should make sure the interval is an integer' do
    line_item.should validate_numericality_of(:interval)
  end
  
end
