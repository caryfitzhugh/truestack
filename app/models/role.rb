class Role
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_and_belongs_to_many :users

  validates_uniqueness_of :name

  def self.find_by_name(name)
    where(name: name.to_s)
  end
end
