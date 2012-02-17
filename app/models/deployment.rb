class Deployment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :commit_id,   type: String
  field :commit_info, type: Hash
  #field :application_actions, type: Hash, default: {}
  embeds_many :application_actions do
    def get(name)
      find(name.to_s)
    end
  end
  belongs_to :user_application

  validates_presence_of :commit_id
  validates_presence_of :user_application

  def req_per_second(now = Time.now)
    total_count = application_actions.inject(0) {|tot, action| tot += action.count }.to_f
    total_count / (now - created_at).to_i
  end

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
  # Add stored function somehow?
  ADD_REQUEST = <<-EOS
    function(deploy_id, action_states) {
      var doc = db.items.findOne({_id: ObjectId(deploy_id)});
      if (!doc) return; // just ignore if can't find it

      doc.updated_at  = new Date();

      for (var key in action_states) {
        var action = doc.application_actions[key];
        var new_duration = action_states[key];

        var count       = ( action.count    || 0) + 1;
        var old_mean    = action.mean     || 0;
        var old_square  = action.square   || 0;


        var new_mean     = old_mean   + ( new_duration - old_mean ) / count;
        var new_square   = old_square + (( new_duration - old_mean) * ( new_duration - new_mean ));

        action.count  = count;
        action.mean   = new_mean;
        action.square = new_square;
      }

      db.items.save(doc);
    }
  EOS
  def inject_message(message)
    Rails.logger.info message
    if (message[:type] == 'request')
      add_request(message[:name], message[:methods])
    else
      false
    end
  end
  def add_request(action_name, method_calls)
    # We want to do an upsert on matching data
    # TODO
    Rails.logger.error "THIS IS BAD! RACE CONDITIONS! - make a JS stored_procedure"

    method_calls.each_pair do |name, timings|
      application_actions.find_or_create_by(name: name.to_s).update(timings)
    end
  end
end
