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
      deployed!("Initial Deploy")
    end
  end

  # This user application was deployed to it's server
  # And so - create a new deployment record
  def deployed!( commit_id, commit_info={}, all_methods={} )
    deployment = Deployment.new(commit_id: commit_id, commit_info: commit_info, methods: all_methods, user_application: self)
    deployment.save!
    deployment
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
