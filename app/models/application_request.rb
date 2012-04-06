class ApplicationRequest
  include Mongoid::Document

  field :name,          type: String
  field :request_id,    type: String
  key   :name
  validates_presence_of :name
  embedded_in :time_bucket
  embeds_many :request_actions

  def update_request(incoming_actions)
    incoming_actions.each_pair do |method_name, executions|
      action = request_actions.find_or_create_by(:name => method_name)
      executions.each do |execution|
        action.increment_stats(execution[:tend] - execution[:tstart])
      end
    end
  end
end
