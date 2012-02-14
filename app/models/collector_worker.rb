class CollectorWorker
  include Mongoid::Document
  include Mongoid::Timestamps
  field :url, type: String
  field :connection_count, type: Integer

  def self.find_available
    CollectorWorker.limit(1).asc(:connection_count).first
  end
end
