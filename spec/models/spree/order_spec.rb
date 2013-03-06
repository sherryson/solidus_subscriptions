require 'spec_helper'


describe Spree::Order do
  let(:user) { stub_model(Spree::LegacyUser, :email => "spree@example.com") }
  let(:order) { stub_model(Spree::Order, :user => user) }

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
      let(:subscription) { stub('Spree::Subscription') }
      let(:interval) { 4 }

      let(:line_items) {[
        FactoryGirl.create(:line_item, interval: nil),
        FactoryGirl.create(:line_item, interval: interval)
      ]}

      before do
        order.stub(:subscribable?).and_return(true)
        order.stub(:repeat_order?).and_return(false)
        order.stub(:subscription=)

        order.stub(:line_items).and_return(line_items)

        ::Spree::Subscription.
          stub(:create!).
          with(ship_address_id: order.ship_address.id,
               user_id: order.user.id,
               interval: interval).
          and_return(subscription)
      end

      it "creates a subscription and attaches it to the order" do
        order.finalize!
        order.subscription.should_not be_nil
        order.subscription.interval.should == interval
      end

      it "does not set the repeat_order flag" do
        order.finalize!

        expect(order.repeat_order).to be_false
      end
    end
  end

  describe '#subscribable?' do
    let(:order) {
      FactoryGirl.create :order,
                         ship_address: FactoryGirl.create(:address)
    }

    subject { order.subscribable? }

    before do
      order.stub(:line_items).and_return(line_items)
    end

    context "without any subscription line-items" do
      let(:line_items) {[ stub('Spree::LineItem', interval: nil) ]}

      it { should be_false }
    end

    context "with one or more subscription line-items" do
      let(:line_items) {[ stub('Spree::LineItem', interval: '2') ]}

      it { should be_true }
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
