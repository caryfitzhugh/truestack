class UserApplication
  include Mongoid::Document
  field :name, :type => String
  has_many :deployments
  has_many :access_tokens

  # Get the latest deployment for a user application
  def latest_deployment
    deployments.desc(:created_at).limit(1).first
  end

  # This user application was deployed to it's server
  # And so - create a new deployment record
  def deployed!( commit_id, commit_info={}, all_methods={} )
    deployment = Deployment.new(commit_id: commit_id, commit_info: commit_info, methods: all_methods, user_application: self)
    deployment.save!
    deployment
  end
end
