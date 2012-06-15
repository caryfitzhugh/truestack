module TimeSlices
  SLICES = { :day => 1.day, :hour => 1.hour , :minute => 1.minute }

  def self.included(base)
    base.send(:extend, TimeSlices::ClassMethods)

    base.instance_eval do
      field :timestamp
      field :slice_type

      TimeSlices::SLICES.each_pair do |name, duration|
        scope "by_#{name}", where(slice_type: name)
      end

      scope :slices_for, lambda {|app, since_time|
        time_end   = Time.now
        time_start = since_time

        # Which one do we use?
        slice_desc = TimeSlices::SLICES.map do |name, duration|

          data = [(time_end - time_start) / duration, name]
          pp data
          data
        end.select do |data|
          # Need more than 10 and < 200
          data.first > 10 && data.first < 200
        end.sort_by do |data|
          data.first
        end.first

        # Default to day
        slice_type = :day
        if slice_desc
          slice_type = slice_desc.last
        end

        self.where(
          :user_application => app,
          :timestamp.gte => TruestackClient.to_timestamp(time_start),
          :timestamp.lte => TruestackClient.to_timestamp(time_end),
          :slice_type    => slice_type)
      }
    end
  end

  module ClassMethods

    def mongo_path(*args)
      array = [args].flatten
      array.map {|v| v.gsub(".", "_") }.join(".")
    end

    def to_timeslice(start, window)
      start = TruestackClient.to_timestamp(start)

      # Convert to MS
      timestamp = (start / (TimeSlices::SLICES[window] * 1000)).to_i * 1000 * TimeSlices::SLICES[window]

      timestamp
    end

    # This will update slices based on the given ID.
    def update_slices(tstart, app)
      TimeSlices::SLICES.each_pair do |name, duration|
        data = {:slice_type => name, :user_application_id => app.id, :timestamp => self.to_timeslice(tstart, name)}
        yield data
      end
    end

  end

end
