require 'spec_helper'

feature 'Orders' do
  stub_authorization!
  context 'Index' do
    scenario 'should allow administrators to filter by orders with a subscription' do
      create(:order, created_at: Time.now + 1.day, completed_at: Time.now + 1.day, number: "R100")
      create(:order, created_at: Time.now - 1.day, completed_at: Time.now - 1.day, number: "R200")
      visit spree.admin_orders_path

      within("table#listing_orders") do
        expect(page).to have_text("Frequency")
      end

      within("table.index tbody tr:first-child") do
        expect(page).not_to have_text("false")
      end
    end
  end
end
