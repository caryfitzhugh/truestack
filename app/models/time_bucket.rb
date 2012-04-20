class TimeBucket
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user_application
  has_many :application_requests
  has_many :application_exceptions
  has_many :application_metrics

  def add_metric(tstart, name, value, meta_data= {})
    application_metrics.create(name: name, created_at: tstart, value: value, meta_data: meta_data)
  end

  def add_exception(request_name, exception_name, tstart, backtrace, env)
    exception = application_exceptions.create(name: request_name)
    exception.update_exception(:backtrace => backtrace, :tstart => tstart, :env => env)
    exception.exception_name = exception_name
    exception.save!
  end

  def add_browser_request(id, tstart, tend)
    request = application_requests.find_by(request_id: name)
    if (request)
      request.add_browser_data(tstart, tend)
      request.save!
    end
  end

  def add_request(name, id, actions)
    # We need to process the actions to get their actual durations
    # subtracting subsequent things from the tree
    # so that we can extract each individual method's timing data
    # Start time should be relative to teh first method (so all should be scaled down.
    # First method has start time of 0
    # CONVERT TO FLOATS
::Rails.logger.error "Need to pre-process the start/end times on the requests!"

    request = application_requests.create(name: name)
    request.request_id = id
    request.update_request(actions)
    request.save!

    save!
  end
end
