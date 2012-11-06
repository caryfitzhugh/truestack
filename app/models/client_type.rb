class ClientType
  include Mongoid::Document

  field :start_on, type: Time
  field :app, type: String
  field :client, type: String

  def self.from_previous_month
    ClientType.where(start_on: self.client_types_key - 1.month)
  end
  def self.from_current_month
    ClientType.where(start_on: self.client_types_key)
  end

  def self.update!(app_version, client_version)
    ClientType.find_or_create_by({app: app_version, client: client_version, start_on: self.client_types_key})
  end

  def self.client_types_key
    Time.now.change(:day => 1, :hour => 0, :minute => 0, :seconds => 0)
  end
end
