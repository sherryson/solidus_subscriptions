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
      end

      it "does not set the repeat_order flag" do
        order.reload
        expect(order.repeat_order).to be_false
      end
    end
  end


  context "#add_variant" do
    let(:order)    { Spree::Order.new }
    let(:variant)  { stub('Spree::Variant').as_null_object }
    let(:currency) { stub('current currency') }

    context "without an interval argument" do
      it "defaults to Spree's natural behaviour" do
        order.should_receive(:add_variant_without_interval).with(variant, 3, currency)

        order.add_variant(variant, 3, currency)
      end
    end

    context "with an interval argument" do
      let(:interval) { '2' }

      context "with an existing standard line-item" do
        pending "discussion of how to handle this use-case"
      end

      context "with an existing subscription line-item" do
        pending "discussion of how to handle this use-case"
      end

      context "without an existing line-item" do
        before(:each) do
          order.stub(:find_line_item_by_variant).with(variant).and_return(nil)
        end

        it "adds a subscription line-item to the order" do
          line_items = mock('line_items')
          line_item = stub('Spree::LineItem').as_null_object

          order.stub(:line_items).and_return(line_items)
          order.stub(:reload)

          ::Spree::LineItem.should_receive(:new).
            with(quantity: 3, interval: '2').
            and_return(line_item)

          line_items.should_receive(:<<).with(line_item)

          result = order.add_variant(variant, 3, interval, currency)

          expect(result).to be(line_item)
        end
      end
    end
  end
end
