class ApplicationRequest
  include Mongoid::Document

  field :name,          type: String
  field :actions,       type: Array, default: []
  key   :name
  validates_presence_of :name
  belongs_to :time_bucket

  def add_browser_data(tstart, tend)
    actions << {type: 'browser', name: 'browser', tend: tend, tstart: tstart}
  end

  def update_request(incoming_actions)
    actions << incoming_actions
  end
end
