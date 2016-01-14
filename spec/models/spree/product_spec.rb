require 'spec_helper'

describe Spree::Product do
  let(:simple_product) { create(:base_product) }
  let(:product) { create(:subscribable_product)}

  it 'should respond to subscribable' do
    product.should respond_to :subscribable?
  end

  it "should be subscribable" do
    expect(product.subscribable?).to be true
  end

  it "should have subscribable to false by default" do
    expect(simple_product.subscribable?).to be false
  end
end
