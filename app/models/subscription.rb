class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  field :plan_id, type: Integer
  field :stripe_customer_token, type: String

end
