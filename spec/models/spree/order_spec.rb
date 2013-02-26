require 'spec_helper'


describe Spree::Order do
  let(:user) { stub_model(Spree::LegacyUser, :email => "spree@example.com") }
  let(:order) { stub_model(Spree::Order, :user => user) }

  it { should respond_to(:subscribable?) }
  it { should respond_to(:repeat_order?) }

  context "#finalize!" do
    let(:order) { Spree::Order.create}
    it 'should receive a call to create a subscription when finalized' do
      order.should_receive(:create_subscription_if_eligible)
      order.finalize!
    end

    it 'should create a subscription only if the order contains eligible products' do
      order = FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address))
      order.finalize!
      order.subscription.should be_nil
    end

    it 'should create a subscription when an eligible product is present' do
      order = FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address))
      order.line_items << FactoryGirl.create(:line_item, variant: FactoryGirl.create(:subscribable_variant))
      order.finalize!
      order.subscription.should be_valid
      order.repeat_order.should be_false
    end
  end

end
