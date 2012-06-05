class StoredProcedure
  include Mongoid::Document
  store_in collection: "system.js"
  field :value, type: Moped::BSON::Code
  field :name,  type: String
  field :_id,   type: String, default: lambda { name }

  def self.method_missing(name, *args)
    arg_names = (1..args.length).map {|i| "a#{i}"}.join(',')
    eval_str = "return function(#{arg_names}) { return #{name}(#{arg_names});}(#{args.map {|v| v.to_json}.join(',')});"
    Mongoid.default_session.send(:current_database).command(:eval => eval_str )['retval']
  end

  def self.store!
    Dir[Rails.root.join('db','mongo_procedures', "*")].each do |file|
      name = File.basename(file)
      contents = File.read(file)

      StoredProcedure.find_or_create_by(name:name, value: Moped::BSON::Code.new(contents))
    end
  end
end
