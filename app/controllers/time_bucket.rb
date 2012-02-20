class TimeBucket
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,  type: String
  field :actions, type: Hash
  key   :name
  belongs_to :user_application
  embeds_many :application_requests
  embeds_many :application_actions

  def add_request(request_name, method_calls)
    application_requests.find_or_create_by(name: request_name).update(method_calls)

    method_calls.each_pair do |name, timings|
      application_actions.find_or_create_by(name: name).update(timings)
    end
    save
  end

end
