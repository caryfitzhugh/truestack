class TimeBucket
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user_application
  embeds_many :application_requests
  embeds_many :application_actions

  def add_request(name, id, actions)
    # We need to process the actions to get their actual durations
    # subtracting subsequent things from the tree
    # so that we can extract each individual method's timing data
    # Start time should be relative to teh first method (so all should be scaled down.
    # First method has start time of 0
    # CONVERT TO FLOATS
::Rails.logger.error "Need to pre-process the start/end times on the requests!"

    request = application_requests.find_or_create_by(name: name)
    request.request_id = id
    request.update_request(actions)

    # TODO
::Rails.logger.error "THIS IS BAD! RACE CONDITIONS! - make a JS stored_procedure"

    actions.each_pair do |method_name, executions|
      action = application_actions.find_or_create_by( :name => method_name)
      executions.each do |execution|
        action.increment_stats(execution[:tend] - execution[:tstart])
      end
    end

    save!
  end
end
