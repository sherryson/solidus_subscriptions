module AuthenticationHelpers
  include Capybara::DSL

  def sign_in_as!(user)
    visit '/login'

    within '#existing-customer' do
      fill_in 'Email',    :with => user.email
      fill_in 'Password', :with => user.password

      click_button 'Login'
    end
  end
end

RSpec.configure do |c|
  c.include AuthenticationHelpers, :type => :request
end
