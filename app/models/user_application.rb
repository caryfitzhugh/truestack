class UserApplication
  include Mongoid::Document

  field :name, type: String
  field :access_counts, type: Hash, default: {}

  validates_uniqueness_of :name, :scope => [:name, :user_id]

  belongs_to :user
  validates_presence_of :user

  has_many :access_counters
  has_many :deployments
  has_one  :access_token
  has_many :application_time_slices

  after_create :create_access_token

  def find_deployment_at(tstart)
    deployment = deployments.where(:tstart.gte => tstart).asc(:tstart).first
    if deployment
      deployment
    else
      Deployment.new
    end
  end

  # This user application was deployed to it's server
  # And so - create a new deployment record
  def add_startup( app_env, tstart, host_id, commit_id, methods = [] )
    Rails.logger.info "Add startup event #{app_env} #{commit_id} : #{host_id}"
    current_access_counter.inc!

    startup = deployments.find_or_create_by({app_env: app_env, commit_id: commit_id})
    startup.add_startup_event(tstart, host_id, methods)
    startup.save!
  end

  def add_browser_ready_timing(app_env, browser_action_name, tstart, tend)
    Rails.logger.info "Add browser request #{browser_action_name} #{app_env} #{tstart} - #{tend}"
    current_access_counter.inc!

    ApplicationTimeSlice.add_browser_ready(self, app_env, browser_action_name, tstart, tend - tstart)
  end

  def add_request(app_env, method_name, actions)
    Rails.logger.info "Add request #{app_env} #{name} #{actions.to_yaml}"
    current_access_counter.inc!

    ApplicationTimeSlice.add_request(self, app_env, method_name, actions)
  end

  def add_exception(app_env, req_name, exception_name, failed_in_method, actions, tstart, backtrace, env)
    Rails.logger.info "Add exception #{app_env} #{req_name} #{exception_name}"
    current_access_counter.inc!

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

  def purge!
    application_time_slices.destroy_all
    deployments_list = deployments.asc(:tstart).to_a

    deployment_saved = deployments_list.pop
    deployments_list.each {|deploy| deploy.destroy}
  end

  def current_access_counter
    AccessCounter.find_or_create_by({user: self.user, user_application: self, start_on: AccessCounter.access_count_key})
  end

  def access_count
    current_access_counter.count
  end
end
