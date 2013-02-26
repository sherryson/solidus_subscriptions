require 'spec_helper'

describe 'Product' do

  before do
    product = create(:product)
    product2 = create(:simple_product)
    user = create(:admin_user, email: "test@example.com")
    sign_in_as!(user)
    visit spree.admin_path
    click_link "Products"
  end

  context 'index page' do

    it 'should indicate which products are subscribable' do
      within("table#listing_products") do
        page.should have_content('subscribable')
      end
    end
  end

  context 'edit product' do
    
    it 'should allow admins to flag as subscribable' do
      within('table.index tbody tr:nth-child(1)') { click_link "Edit" }
      check('product_subscribable')
      click_button 'Update'
      page.should have_content('successfully updated!')
      page.has_checked_field?('product_subscribable').should == true
    end

  end

end
