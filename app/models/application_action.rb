class ApplicationAction
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name,  type: String
  field :count, type: Float, default: 0
  field :mean, type: Float, default: 0
  field :square, type: Float, default: 0
  key   :name

  embedded_in :deployment
  validates_presence_of :name

  # http://mrdanadams.com/2011/mongodb-eval-ruby-driver/
  # Want to make this a JS atomic
  def update(timing)
    count       = self.count + 1
    old_mean    = self.mean
    old_square  = self.square

    new_mean     = old_mean   + ( timing - old_mean ) / count;
    new_square   = old_square + (( timing - old_mean) * ( timing - new_mean ));

    self.count = count
    self.mean  = new_mean
    self.square= new_square
  end
  def stddev
    if (count > 1)
      square / (count - 1)
    else
      0
    end
  end
end
