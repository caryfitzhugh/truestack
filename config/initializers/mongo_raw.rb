require 'mongo'

module MongoRaw
  def self.db
    @db ||= self.connect!
  end
  def self.connect!
    config = YAML.load_file("#{Rails.root}/config/mongoid.yml")[Rails.env].symbolize_keys
    database = if (config[:uri])
      conn = Mongo::Connection.from_uri(config[:uri])
      conn.db(URI.parse(config[:uri]).path.gsub(/^\//, ''))
    else
      conn = Mongo::Connection.new(config[:host], config[:port])
      conn[config[:database]]
    end
    self.store_procedures!(database)
    database
  end
  def self.eval(*args)
    name = args.shift
    arg_names = (1..args.length).map {|i| "a#{i}"}.join(',')
    #eval_str = "function(#{arg_names}) { return #{name}(#{arg_names});}(#{args.map {|v| v.to_json}.join(',')});"
    eval_str = "return #{name}(#{args.map {|v| v.to_json}.join(',')});"
    binding.pry
    self.db.eval(eval_str)
  end
  def self.store_procedures!(database)
    Dir[Rails.root.join('db','mongo_procedures', "*")].each do |file|
      name = File.basename(file)
      contents = File.read(file)
      database['system.js'].save({_id:name, value:BSON::Code.new(contents)});
    end
  end
end
