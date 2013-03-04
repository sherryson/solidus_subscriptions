module Spree
  class Subscription < ActiveRecord::Base
    has_many :orders
    belongs_to :user
    attr_accessible :ship_address_id, :state, :user_id, :interval

    validates_presence_of :ship_address_id
    validates_presence_of :user_id
    validates :interval, numericality: { only_integer: true }
  end
end
