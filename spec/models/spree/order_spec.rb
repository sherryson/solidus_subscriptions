require 'spec_helper'


describe Spree::Order do
  let(:user) { stub_model(Spree::LegacyUser, :email => "spree@example.com") }
  let(:order) { stub_model(Spree::Order, :user => user) }

  it { should respond_to(:subscribable?) }
  it { should respond_to(:repeat_order?) }
  it { should respond_to(:has_subscription?) }

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
