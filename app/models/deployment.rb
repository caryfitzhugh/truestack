class Deployment
  include Mongoid::Document

  field :tstart,     type: Integer
  field :hosts,      type: Array,  default: []
  field :commit_id,  type: String
  field :methods,    type: Hash, default: {}

  belongs_to :user_application

  def classify_method(klass, method=nil)
    name = klass
    if method
      name = "#{klass}##{method}"
    end

    begin
      self.methods[name][:classification] || 'unknown'
    rescue NoMethodError
      'unknown'
    end
  end

  def add_startup_event(tstart, host_id, methods)
    # Set the tstart if this is the first time you've seen it
    self.tstart = TruestackClient.to_timestamp(self.tstart || tstart)

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
