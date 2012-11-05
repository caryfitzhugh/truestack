class AccessCounter
  include Mongoid::Document
  belongs_to :user
  belongs_to :user_application
  field :start_on, type: Time
  field :count, type: Integer, default: 0

  def inc!
    self.inc(:count, 1)
  end
  def self.access_count_key
    Time.now.change(:day => 1, :hour => 0, :minute => 0, :seconds => 0)
  end
end
