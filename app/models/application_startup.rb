class ApplicationStartup
  include Mongoid::Document

  field :tstart,     type: Time
  field :hosts,      type: Array,  default: []
  field :commit_id,  type: String
  field :methods,    type: Hash, default: {}

  belongs_to :user_application

  def add_startup_event(tstart, host_id, methods)
    # Set the tstart if this is the first time you've seen it
    self.tstart = self.tstart || tstart

    # Set the hosts (uniq them, no Set functionality in Mongoid :( )
    self.hosts << host_id
    self.hosts.uniq!

    # Pull apart the methods, and put them into the update
    methods.each do |data|
      klass = data[0]
      method = data[1]
      location = data[2]
      classification = data[3]
      self.methods["#{klass}##{method}"] = {:location => location, :classification => classification}
    end
  end
end
