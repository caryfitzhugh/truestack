module UserApplicationsHelper
  # Like TOP, but CPU
  # Find oldest timestamp and newest slice.
  # Compare the duration, vs the total of slice.methods.all.duration
  # That's your app's "load"
  def get_app_load(slices)
    tstart = slices.first.timestamp
    tend   = slices.last.timestamp

    total  = slices.inject(0) do |sum, slice|
      sum + (slice.method_types['all']['duration'] || 0)
    end
    total / (tend.to_f - tstart)
  end

  def extract_request_counts_for_app_show(slices)
    slices.map do |slice|
      [ slice.timestamp, slice.method_types['all']['count']]
    end
  end

  def extract_stacked_response_times_for_app_show(slices)
    types = Hash.new {|h,k| h[k] = [] }

    type_keys = slices.map do |slice|
      slice.method_types.keys
    end.flatten.uniq

    # Now we have all the keys.
    # Iterate over each slice, looking for the key (or 0)
    type_keys.sort.map do |type|
      [ type,
        slices.map do |slice|
          type_timings = slice.method_types[type]
          count = if type_timings
              type_timings['duration'] / type_timings['count']
            else
              0
            end
          [slice.timestamp, count ]
        end]
    end
  end
  def extract_deployment_data_for_app_show(deploys)
    deploys.map do |deploy|
      [deploy.tstart, deploy.commit_id]
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
