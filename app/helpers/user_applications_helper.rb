module UserApplicationsHelper
  def get_app_uptime(slices)
    tstart = slices.first.timestamp
    tend = TruestackClient.to_timestamp(Time.now)
    return tend - tstart
  end

  # Like TOP, but CPU
  # Find oldest timestamp and newest slice.
  # Compare the duration, vs the total of slice.methods.all.duration
  # That's your app's "load"
  def get_app_load(slices)
    tstart = slices.first.timestamp
    tend = TruestackClient.to_timestamp(Time.now)

    total  = slices.inject(0) do |sum, slice|
      sum + (slice.method_types['all']['duration'] || 0)
    end
    total / (tend.to_f - tstart)
  end

  def extract_request_counts_for_app_show(slices)
    slices.map do |slice|
      { x: slice.timestamp, y: slice.method_types['all']['count'].to_i}
    end
  end

  def extract_stacked_response_times_for_app_show(slices)
    types = Hash.new {|h,k| h[k] = [] }

    # We want - for rickshaw:
    # serieses: [
    #    {  // These are the type 1
    #       data: [ {x: 0, y: total height}, ....]
    #    },
    #    // These are for type #2
    #    // These are for type #3
    #
    # ]

    type_keys = slices.map do |slice|
      slice.method_types.keys
    end.flatten.uniq - ['all']

    cumulative_counts = Hash.new {|h,k| h[k] = Hash.new {|h2,k2| h2[k2] = 0} }

    # Now we have all the keys.
    # Iterate over each slice, looking for the key (or 0)
    type_keys.sort.map do |type|
        data = slices.map do |slice|
          type_timings = slice.method_types[type]
          resp_time = if type_timings
              type_timings['duration'] / type_timings['count']
            else
              0
            end
          cum_count = cumulative_counts[type][slice.timestamp]
          result = {x: slice.timestamp, y: resp_time + cum_count }
          cumulative_counts[type][slice.timestamp] += resp_time
          result
        end
        { name: type, data: data}
    end
  end

  def extract_deployment_data_for_app_show(deploys)
    deploys.map do |deploy|
      [deploy.tstart, deploy.commit_id]
    end
  end

  def extract_request_data_for_app_show(slices, deployments)
    method_names = deployments.map do |deploy|
                    deploy.methods.keys
                   end + slices.map do |slice|
                    slice.actions.keys
                   end

    method_names = method_names.flatten.map(&:underscore).uniq

    # Method name => has this data:
    #   {:avg_duration / slice
    #    :avg_requests / slice
    #    :avg_exceptions / slice
    #    :
    method_names.sort.map do |name|
      req_times = slices.map {|slice| slice.actions[name]['method_types']['all']['duration']  rescue 0}
      req_count = slices.map {|slice| slice.actions[name]['method_types']['all']['count'] rescue 0 }
      exception_count = slices.map {|slice| slice.actions[name]['exceptions'].length rescue 0}

      { :name => name,
        :req_times => req_times,
        :req_count => req_count,
        :exception_count => exception_count,
        :slope_times => get_slope(req_times),
        :slope_count => get_slope(req_count),
        :slope_exceptions => get_slope(exception_count)
      }
    end
  end

  def extract_exception_data_for_app_show(slices)
    exceptions = slices.map do |slice|
      slice.actions.map do |req_name, data|
        data['exceptions']
      end.compact
    end.flatten(2)
  end
end
