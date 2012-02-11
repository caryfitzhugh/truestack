class CollectorWorker < ActiveRecord::Base
  def self.find_available
    CollectorWorker.order("connection_count ASC").first
  end
end
