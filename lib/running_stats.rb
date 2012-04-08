module RunningStats
  def self.included(klass)
    klass.class_eval do
      field :mean, type: Float, default: 0
      field :square, type: Float, default: 0
      field :count , type: Integer, default: 0
    end
  end
  def self.increment_stats_for field

    field "#{field}_mean", type: Float, default: 0
    field "#{field}_square", type: Float, default: 0
    field "#{field}_count", type: Integer, default: 0
    define_method "#{field}_stddev" do
      if (send("#{field}_count") > 1)
        send("#{field}_square") / (send("#{field}_count") - 1)
      else
        0
      end
    end

    define_method "increment_#{field}" do |new_value|
      duration = new_value.to_f

      # Update count one time
      count       = self.send("#{field}_count") + 1

      # Duration
      old_mean    = self.send("#{field}_mean")
      old_square  = self.send("#{field}_square")

      new_mean     = old_mean   + ( duration - old_mean ) / count;
      new_square   = old_square + (( duration - old_mean) * ( duration - new_mean ));

      self.send("#{field}_mean=", new_mean)
      self.send("#{field}_square=",  new_square)

      # Save count
      self.send("#{field}_count=", count)
    end
  end
end
