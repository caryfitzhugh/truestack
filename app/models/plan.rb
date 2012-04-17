class Plan
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :price, type: Decimal
  field :stripe_customer_token, type: String

end
