class UserApplication
  include Mongoid::Document
  field :name, :type => String
  has_many :deployments
  has_many :time_buckets
  has_many :access_tokens

  BUCKET_RESOLUTION_IN_SECONDS = 300  # 5 minutes

  # Get the latest deployment for a user application
  def latest_deployment
    deploy = deployments.desc(:created_at).limit(1).first
    if (deploy)
      deploy
    else
      deploy!(:commit_id => "Initial Deploy")
    end
  end

  # This user application was deployed to it's server
  # And so - create a new deployment record
  def deploy!( message )
    commit_id = message.delete(:commit_id)
    all_actions = message.delete(:all_actions) || {}
    deployment = Deployment.create!(commit_id: commit_id, commit_info: message, methods: all_actions, user_application: self)
  end

  def add_request(request_name, timestamp, method_calls)
    Rails.logger.info "Add request #{request_name} #{timestamp} #{method_calls}"
    current_bucket.add_request(request_name, timestamp, method_calls)
    current_bucket.save
  end

  # Get the latest bucket
  def current_bucket
    timestamp = (Time.now.to_i / BUCKET_RESOLUTION_IN_SECONDS) * BUCKET_RESOLUTION_IN_SECONDS
    time_buckets.find_or_create_by(created_at: timestamp)
  end
end
