module RunningStats
  def self.included(klass)
    klass.class_eval do
      field :mean, type: Float, default: 0
      field :square, type: Float, default: 0
      field :count , type: Integer, default: 0
    end
  end

  def increment_stats(new_duration)
    duration = new_duration.to_f

    # Update count one time
    count       = self.count + 1

    # Duration
    old_mean    = self.mean
    old_square  = self.square

    new_mean     = old_mean   + ( duration - old_mean ) / count;
    new_square   = old_square + (( duration - old_mean) * ( duration - new_mean ));

    self.mean  = new_mean
    self.square= new_square

    # Save count
    self.count = count
    self
  end

  def stddev
    if (count > 1)
      square / (count - 1)
    else
      0
    end
  end
end
