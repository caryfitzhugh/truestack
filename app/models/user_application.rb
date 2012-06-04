class UserApplication
  include Mongoid::Document

  field :name, type: String
  belongs_to :user

  has_many :deployments
  has_one  :access_token

  after_create :create_access_token

  def find_deployment_at(tstart)
    deployment = deployments.where(:tstart.gte => tstart).order_by(:tstart => Mongo::ASCENDING).limit(1).first
    if deployment
      deployment
    else
      Deployment.new
    end
  end

  # This user application was deployed to it's server
  # And so - create a new deployment record
  def add_startup( tstart, host_id, commit_id, methods = [] )
    Rails.logger.info "Add startup event #{commit_id} : #{host_id}"
    startup = deployments.find_or_create_by({commit_id: commit_id})
    startup.add_startup_event(tstart, host_id, methods)
    startup.save!
  end

  def add_browser_ready_timing(browser_action_name, tstart, tend)
    Rails.logger.info "Add browser request #{browser_action_name} #{tstart} - #{tend}"
    ApplicationTimeSlice.add_browser_ready(self, browser_action_name, tstart, tend - tstart)

    #TimeSlice.add_browser_ready_timing(self.id, browser_action_name, tstart, tend-tstart)
  end

  def add_request(method_name, actions)
    Rails.logger.info "Add request #{name} #{actions.to_yaml}"

    ApplicationTimeSlice.add_request(self.id, method_name, actions)
  end

  def add_exception(req_name, exception_name, failed_in_method, actions, tstart, backtrace, env)
    Rails.logger.info "Add exception #{req_name} #{exception_name}"

    ApplicationTimeSlice.add_exception(self, req_name, exception_name, tstart)

    #TimeSlice.add_exception(self.id,
    #                        req_name,
    #                        exception_name,
    #                        failed_in_method,
    #                        actions,
    #                        tstart,
    #                        backtrace,
    #                        env)
  end

  def create_access_token
    token = AccessToken.create!(:user_application=>self)
    self.access_token = token
  end

  private

  def current_deploy_key
    deployment = deployments.order_by(['tstart', :desc]).first
    if (deployment)
      deployment.commit_id
    else
      'default-deploy-key'
    end
  end
end
