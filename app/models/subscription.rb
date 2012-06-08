class Subscription
  include Mongoid::Document
  field :plan_id, type: Integer
  field :user_id, type: Integer
  field :stripe_card_token
  field :stripe_customer_token


  def save_with_payment(user)
    if valid?
      customer = Stripe::Customer.create(description: "User ID: #{user.id}", email: user.email, plan: plan_id, card: stripe_card_token)
      self.stripe_customer_token = customer.id
      save!
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end
end
