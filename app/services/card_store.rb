class CardStore

  class CardError < StandardError
  end

  def self.store_card_for_user(user, card, cvc)
    if user.stripe_customer?
      self.create_card_for_user(user, card, cvc)
    else
      self.create_customer(user, card, cvc)
    end
  end

  private

  def self.create_card_for_user(user, card, cvc)
    cu = user.is_a?(Stripe::Customer) ? user : Stripe::Customer.retrieve(user.stripe_id)
    card_params = {
      object: 'card',
      number: card.number,
      cvc: cvc,
      exp_month: card.month,
      exp_year: card.year
    }
    response = cu.sources.create(source: card_params)
    card.update_column(:gateway_customer_profile_id, response[:customer])
    card.update_column(:gateway_payment_profile_id, response[:id])
  rescue => e
    user.create_log_entry(e.to_s) if e.is_a?(Stripe::StripeError)
    card.errors.add(:base, e)
    raise CardError, e
  end

  def self.create_customer(user, card, cvc)
    cu = Stripe::Customer.create(email: user.email)
    create_card_for_user(cu, card, cvc)
  rescue => e
    gateway_error e
  end

  private
  def self.gateway_error(error)
    if error.is_a? ActiveMerchant::Billing::Response
      text = error.params['message'] || error.params['response_reason_text'] || error.message
    elsif error.is_a? ActiveMerchant::ConnectionError
      text = I18n.t(:unable_to_connect_to_gateway)
    else
      raise CardError
    end
  end

end