class ApplicationTimeSlice
  include Mongoid::Document
  include TimeSlices
  belongs_to :user_application

  field :actions,      :type => Hash, :default => {}
  field :method_types, :type => Hash, :default => {}

  # DOCUMENT
  #
  #
  #   method_types.all.count:    # of requests in this slice
  #   method_types.all.duration: # ms spent in this slice
  #   method_types.browser.duration: # ms spent in this slice
  #   method_types.browser.count: # ms spent in this slice
  #   method_types.<type>.count  # For the given type
  #   method_types.<type>.total
  #
  #   actions:
  #     controller#action => {
  #       exceptions: [ [ time, name] ]
  #       method_types: { same as above... all, and other types }
  #     }
  def self.add_browser_ready(user_application, req_name, tstart, duration)
    increments = {
      "method_types.all.count"         => 0,
      "method_types.all.duration"      => duration,
      "method_types.browser.count"     => 1,
      "method_types.browser.duration"  => duration
    }

    update_slices(tstart, user_application) do |slice_args|
      collection.find(slice_args).upsert("$inc" => increments)
    end
  end

  def self.add_exception(user_application, req_name, exception_name, tstart)
    update_slices(tstart, user_application) do |slice_args|
      collection.find(slice_args).upsert('$push' => {mongo_path("actions", req_name, "exceptions") => [tstart, exception_name]})
    end
  end

  def self.add_request(user_application, method_name, actions)
    tree = CallTree.new(actions)
    tstart = tree.root[:tstart]
    request_duration = tree.root[:duration]

    # Look up the deployment data at the given time, and
    # return the classified method timings
    total_times = tree.apply_method_classification(user_application)

    # method_types.all.count_n_duration
    #
    # actions.method#name.method_types.all.count_n_duration
    increments = {
        "method_types.all.count" => 1,
        "method_types.all.duration" => request_duration,
        mongo_path("actions", method_name, "method_types","all","count") => 1,
        mongo_path("actions", method_name, "method_types","all","duration") => request_duration
      }

    # method_types.<type>.count_n_duration
    #
    # actions.method#name.method_types.<type>.count_n_duration
    total_times.each_pair do |classification, duration|
      increments[mongo_path('method_types',classification,'count')] = 1
      increments[mongo_path('method_types',classification,'duration')] = duration
      increments[mongo_path("actions", method_name, "method_types",classification,"count")] = 1
      increments[mongo_path("actions", method_name, "method_types",classification,"duration")] = duration
    end

    update_slices(tstart, user_application) do |slice_args|
      collection.find(slice_args).upsert( '$inc' => increments )
    end
  end
end
