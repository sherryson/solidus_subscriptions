source 'http://rubygems.org'

gem 'spree', github: 'spree/spree', branch: '2-4-stable'
# Provides basic authentication functionality for testing parts of your engine
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: '2-4-stable'
gem 'active_model_serializers', '~> 0.8.3'

group :test do
  gem 'factory_girl', '4.5.0'
  gem 'launchy'
  gem "shoulda-matchers", '2.8.0'
  gem 'haml-rails'
  gem 'database_cleaner', '1.4.1'
  gem 'timecop'
  gem 'guard-rspec', require: false
end

gemspec
