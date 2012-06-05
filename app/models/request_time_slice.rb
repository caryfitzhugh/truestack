class RequestTimeSlice
  include Mongoid::Document
  include TimeSlices
  # ADD THESE PIECES OF DATA
  # AND BE ABLE TO QUERY THEM.
  # find_slices( ) needs to call super and add the where(request_name == ...)
  #
  #
  # request_name: ALWAYS SET WITH UPDATE
  # exceptions:   name, [....times]
  #
  # classifications.<all or type>.count
  # classifications.<all or type>.duration
  # classifications.<all or type>.stddev
  # classifications.browser.count, duration, stddev
  #
  # tree:
  #   exceptions
  #   stddev,mean,count
  #   calls =>
  def self.add_exception( )

  end

  def self.add_browser_ready(user_application, req_name, tstart, duration)

  end

  def self.add_request(user_application, method_name, actions)

  end
end
