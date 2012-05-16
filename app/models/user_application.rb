class UserApplication
  include Mongoid::Document

  field :name, type: String
  field :owner, type: String

  has_many :time_slices
  has_many :access_tokens
  has_many :application_startups

  after_save :create_default_access_token

  # This user application was deployed to it's server
  # And so - create a new deployment record
  def add_startup( tstart, host_id, commit_id, methods = [] )
    Rails.logger.info "Add startup event #{commit_id} : #{host_id}"
    startup = application_startups.find_or_create_by({commit_id: commit_id})
    startup.add_startup_event(tstart, host_id, methods)
    startup.save!
  end

  def add_browser_ready_timing(action_name, tstart, tend)
    Rails.logger.info "Add browser request #{action_name} #{tstart} - #{tend}"
    TimeSlice.add_browser_ready_timing(self.id, current_deploy_key, action_name, tstart, tend-tstart)
  end

  def add_request(method_name, actions)
    Rails.logger.info "Add request #{name} #{actions.to_yaml}"
    TimeSlice.add_request(self.id, current_deploy_key, method_name, actions)
  end

  def add_exception(req_name, exception_name, tstart, backtrace, env)
    Rails.logger.info "Add exception #{req_name} #{exception_name}"
    TimeSlice.add_exception(self.id, req_name, exception_name, tstart, backtrace, env)
  end

  private

  def create_default_access_token
    if (self.access_tokens.length == 0)
      self.access_tokens.create!
    end
  end

  def current_deploy_key
    deployment = application_startups.order_by(['tstart', :desc]).first
    if (deployment)
      deployment.commit_id
    else
      'default-deploy-key'
    end
  end
end
