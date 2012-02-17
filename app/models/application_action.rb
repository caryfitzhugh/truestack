class ApplicationAction
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,  type: String
  field :count, type: Float, default: 0
  field :start_mean, type: Float, default: 0
  field :start_square, type: Float, default: 0
  field :duration_mean, type: Float, default: 0
  field :duration_square, type: Float, default: 0
  key   :name

  embedded_in :deployment
  validates_presence_of :name

  # http://mrdanadams.com/2011/mongodb-eval-ruby-driver/
  # Want to make this a JS atomic
  #
  # S is start time
  # D is duration
  def update(timing)
    timing = {s: 0.0, d: 0.0}.merge(timing.symbolize_keys)
    timing[:d] = timing[:d].to_f
    timing[:s] = timing[:s].to_f

    # Update count one time
    count       = self.count + 1

    # Duration
    old_mean    = self.duration_mean
    old_square  = self.duration_square

    new_mean     = old_mean   + ( timing[:d] - old_mean ) / count;
    new_square   = old_square + (( timing[:d] - old_mean) * ( timing[:d] - new_mean ));

    self.duration_mean  = new_mean
    self.duration_square= new_square

    # Start
    old_mean    = self.start_mean
    old_square  = self.start_square

    new_mean     = old_mean   + ( timing[:s] - old_mean ) / count;
    new_square   = old_square + (( timing[:s] - old_mean) * ( timing[:s] - new_mean ));

    self.start_mean  = new_mean
    self.start_square= new_square

    # Save count
    self.count = count
  end
  def duration_stddev
    if (count > 1)
      duration_square / (count - 1)
    else
      0
    end
  end
  def start_stddev
    if (count > 1)
      start_square / (count - 1)
    else
      0
    end
  end
end
