require 'spec_helper'

describe 'Orders' do
  before do
    create(:order, :created_at => Time.now + 1.day, :completed_at => Time.now + 1.day, :number => "R100")
    create(:order, :created_at => Time.now - 1.day, :completed_at => Time.now - 1.day, :number => "R200")
    user = create(:admin_user, email: "test@example.com")
    sign_in_as!(user)
    visit spree.admin_orders_path
  end

  context 'Orders Index' do
    it 'should allow administrators to filter by orders with a subscription' do
      within("table#listing_orders") do
        page.should have_content('subscription')
      end
      within("table.index tbody tr:first-child") do
        page.should have_content('false')
      end
    end
  end
end
