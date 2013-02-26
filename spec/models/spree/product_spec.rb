require 'spec_helper'

describe Spree::Product do

  let(:product) { Factory(:subscribable_product) }
  let(:simple_product) { Factory(:simple_product) }

  it 'should respond to subscribable' do
    product.should respond_to :subscribable
  end

  it "should be subscribable" do
    product.subscribable.should be_true
  end

  it "should have subscribable to false by default" do
    simple_product.subscribable?.should be false
  end 

end
