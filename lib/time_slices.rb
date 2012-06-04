module TimeSlices
  SLICES = { :day => 1.day, :hour => 1.hour }

  def self.included(base)
    base.send(:extend, TimeSlices::ClassMethods)
  end

  module ClassMethods
    def find_slices(user_app, since_time)
      time_end   = Time.now
      time_start = time_end - since_time

      # Which one do we use?
      slice_type = TimeSlices::SLICES.each_pair do |name, duration|
        [(time_end - time_start / duration), name]
      end.sort_by do |data|
        # Want at least 20 records, but try for no more than 50, then get the most
        [data.first > 20, data.first < 50, data.first]
      end.first.last

      self.where(
        :_id.gte => self.slice_id(time_start, user_app.id, slice_type),
        :_id.lte => self.slice_id(time_end,   user_app.id, slice_type))
    end

    def mongo_path(*args)
      array = [args].flatten
      array.map {|v| v.gsub(".", "_") }.join(".")
    end

    def slice_id(start, app_id, window)
      start = TruestackClient.to_timestamp(start)

      # Convert to MS
      timestamp = (start / (TimeSlices::SLICES[window] * 1000)).to_i * 1000 * TimeSlices::SLICES[window]

      self.mongo_path("#{app_id}-#{window}-#{timestamp}")
    end

    # This will update slices based on the given ID.
    def update_slices(tstart, app_id)
      TimeSlices::SLICES.each_pair do |name, duration|
        slice_id = self.slice_id(tstart, app_id, name)
        yield slice_id
      end
    end

  end

end
