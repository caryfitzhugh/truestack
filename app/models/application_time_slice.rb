class ApplicationTimeSlice
  include Mongoid::Document
  include TimeSlices
  belongs_to :user_application

  # DOCUMENT
  #   classifications.all.count:    # of requests in this slice
  #   classifications.all.duration: # ms spent in this slice
  #   classifications.browser.duration: # ms spent in this slice
  #   classifications.browser.count: # ms spent in this slice
  #   classifications.<type>.count  # For the given type
  #   classifications.<type>.total
  #
  #   exceptions.<name> => [ time, time, time, time, ....]
  def self.add_browser_ready(user_application, req_name, tstart, duration)
    increments = {
      "classifications.all.count"         => 0,
      "classifications.all.duration"      => duration,
      "classifications.browser.count"     => 1,
      "classifications.browser.duration"  => duration
    }

    update_slices(tstart, user_application) do |slice_args|
      collection.find(slice_args).upsert("$inc" => increments)
    end
  end

  def self.add_exception(user_application, req_name, exception_name, tstart)
    update_slices(tstart, user_application) do |slice_args|
      collection.find(slice_args).upsert('$push' => {mongo_path("exceptions",exception_name) => [tstart]})
    end
  end

  def self.add_request(user_application, method_name, actions)

    tree = CallTree.new(actions)
    tstart = tree.root[:tstart]
    request_duration = tree.root[:duration]

    # Look up the deployment data at the given time, and
    # return the classified method timings
    total_times = tree.apply_method_classification(user_application)
    increments = {
              "classifications.all.count" => 1,
              "classifications.all.duration" => request_duration
            }

    total_times.each_pair do |classification, duration|
      increments[mongo_path('classifications',classification,'count')] = 1
      increments[mongo_path('classifications',classification,'duration')] = duration
    end

    update_slices(tstart, user_application) do |slice_args|
      collection.find(slice_args).upsert( '$inc' => increments )
    end

  end
end
