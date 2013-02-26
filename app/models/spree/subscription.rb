module Spree
  class Subscription < ActiveRecord::Base
    has_many :orders
    belongs_to :user
    attr_accessible :ship_address_id, :state, :user_id

    validates_presence_of :ship_address_id
    validates_presence_of :user_id

  end
end
