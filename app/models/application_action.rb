class ApplicationAction
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,  type: String
  field :count, type: Float, default: 0

  field :mean, type: Float, default: 0
  field :square, type: Float, default: 0
  key   :name

  embedded_in :time_bucket
  validates_presence_of :name

  # http://mrdanadams.com/2011/mongodb-eval-ruby-driver/
  # Want to make this a JS atomic
  # http://railstips.org/blog/archives/2011/06/28/counters-everywhere/
  #
  # http://www.johndcook.com/standard_deviation.html
  # Want to calculate running mean, variance, stddev
  # m_newM = m_oldM + (x - m_oldM) / m_n;
  # m_newS = m_oldS + (x - m_oldM) * (x - m_newM);
  #
  # // set up for next iteration
  # m_oldM = m_newM;
  # m_oldS = m_newS;
  #
  # NumDataValues()     return m_n;
  # Mean()              return (m_n > 0) ? m_newM : 0.0;
  # Variance()          return ( (m_n > 1) ? m_newS/(m_n - 1) : 0.0 );
  # StandardDeviation() return sqrt( Variance() );
  #
  # http://mrdanadams.com/2011/mongodb-eval-ruby-driver/
  #
  # S is start time
  # D is duration
  def update(timing)
    duration = timing.to_f

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
  end
  def stddev
    if (count > 1)
      square / (count - 1)
    else
      0
    end
  end
end
