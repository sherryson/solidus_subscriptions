Spree Subscriptions
==================

This extension allows for administrators to mark certain products as
'susbscribable'. Products marked as such will allow shopers to decide to
create a subscription to automatically have those items re-shipped to
them at the interval of their chosing.

Features
=======


Installation
========

Add the gem to your Gemfile:

    gem 'solidus_subscriptions', github: 'glossier/solidus_subscriptions'
    bundle install

Run the generator and the included migrations:

    rails g solidus_subscriptions:install



Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2013 [Dynamo], released under the New BSD License
