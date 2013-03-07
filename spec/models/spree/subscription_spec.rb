require 'spec_helper'

describe Spree::Subscription do
  it { should have_many(:orders) }
  it { should belong_to(:user) }
end
