require 'spec_helper'


describe Spree::Order do
  let(:user) { stub_model(Spree::LegacyUser, :email => "spree@example.com") }
  let(:order) { stub_model(Spree::Order, :user => user) }
  let(:line_items) {[
    FactoryGirl.create(:line_item),
    FactoryGirl.create(:line_item, variant: FactoryGirl.create(:subscribable_variant))
  ]}

  it { should respond_to(:subscribable?) }
  it { should respond_to(:repeat_order?) }
  it { should respond_to(:has_subscription?) }

  context "#finalize!" do
    let(:order) {
      FactoryGirl.create(:order, ship_address: FactoryGirl.create(:address))
    }

    context "with an ineligible order" do
      before do
        order.stub(:subscribable?).and_return(false)
        order.stub(:repeat_order?).and_return(false)
      end

      it "finalizes the order" do
        order.should_receive(:finalize_without_create_subscription!)

        order.finalize!
      end

      it "doesn't create a subscription" do
        order.finalize!

        expect(order.subscription).to be_nil
      end
    end

    context "with an eligible order" do

      before do
        Spree::OptionType.create(name: 'frequency', presentation: 'frequency')
        order.line_items << line_items
        order.finalize!
        order.stub(:repeat_order?).and_return(false)
      end

      it "creates a subscription and attaches it to the order" do
        order.subscription.should_not be_nil
        order.subscription.duration.should be_nil
      end

      it "does not set the repeat_order flag" do
        order.reload
        expect(order.repeat_order).to be_false
      end
    end
  end
end
