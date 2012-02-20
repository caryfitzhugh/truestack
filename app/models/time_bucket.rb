class TimeBucket
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user_application
  has_many :application_requests
  has_many :application_actions

  def add_request(request_name, method_calls)
    application_requests.find_or_create_by(name: request_name).update(method_calls)

    # TODO
    Rails.logger.error "THIS IS BAD! RACE CONDITIONS! - make a JS stored_procedure"

    method_calls.each_pair do |name, timings|
      application_actions.find_or_create_by(name: name.to_s).update(timings)
    end
    save!
  end
end
