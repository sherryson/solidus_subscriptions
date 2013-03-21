require 'spec_helper'

describe Spree::Product do

  let(:product) { Factory(:subscribable_product) }
  let(:simple_product) { Factory(:simple_product) }

  it 'should respond to subscribable' do
    product.should respond_to :subscribable?
  end

  it "should be subscribable" do
    Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
    product.subscribable?.should be_true
  end

  it "should have subscribable to false by default" do
    simple_product.subscribable?.should be false
  end 

  it "should return a list of subscribable variants" do
    frequency = Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
    two_weeks = Spree::OptionValue.create!({ name: 2, presentation: 'Every 2 weeks', option_type: frequency }, without_protection: true)
    product = FactoryGirl.create(:product)
    product.variants << FactoryGirl.create(:variant, sku: 'non-subscribable', product: product)
    product.variants << FactoryGirl.create(:variant, sku: 'subscribable', product: product, option_values: [two_weeks])
    product.subscribable_variants.map(&:sku).should == ['subscribable']
  end

end
