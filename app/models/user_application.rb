class UserApplication
  include Mongoid::Document

  field :name, type: String
  field :owner, type: String

  has_many :time_buckets
  has_many :access_tokens

  after_save :create_default_access_token

  BUCKET_RESOLUTION_IN_SECONDS = 120  # 2 minutes

  # This user application was deployed to it's server
  # And so - create a new deployment record
  def add_startup( tstart, host_id, commit_id, methods = [] )
    Rails.logger.info "Add startup event #{commit_id} : #{host_id}"
    current_bucket.add_startup(tstart, host_id, commit_id, methods)
  end

  def add_metric(tstart, name, value, meta_data = {})
    Rails.logger.info "Add metric event #{name} : #{value} - #{tstart}"
    current_bucket.add_metric(tstart, name, value, meta_data)
  end

  def add_browser_event(action_name, tstart, tend)
    Rails.logger.info "Add browser request #{action_name} #{tstart} - #{tend}"
    current_bucket.add_browser_request(action_name, tstart, tend)
  end

  def add_request(name, actions)
    Rails.logger.info "Add request #{name} #{actions.to_yaml}"

    current_bucket.add_request(name, actions)
    current_bucket.save
  end

  def add_exception(req_name, exception_name, tstart, backtrace, env)
    Rails.logger.info "Add exception #{req_name} #{exception_name}"
    current_bucket.add_exception(req_name, exception_name, tstart, backtrace, env)
  end

  # Get the latest bucket
  def current_bucket
    timestamp = (Time.now.to_i / BUCKET_RESOLUTION_IN_SECONDS) * BUCKET_RESOLUTION_IN_SECONDS
    time_buckets.find_or_create_by(created_at: timestamp)
  end

  private

  def create_default_access_token
    if (self.access_tokens.length == 0)
      self.access_tokens.create!
    end
  end
end
