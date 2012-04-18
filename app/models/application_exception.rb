class ApplicationException
  include Mongoid::Document

  field :name,              type: String
  field :exception_name,    type: String
  field :details,           type: Hash,  default: {}
  key   :name

  validates_presence_of :name
  belongs_to :time_bucket

  def update_exception(data)
    details = data
  end
end
