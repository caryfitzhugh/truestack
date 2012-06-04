require 'mongo'

module MongoRaw
  def self.db
    @db ||= self.connect!
  end

  def self.connect!
    config = YAML.load(ERB.new(File.read(Rails.root.join("config","mongoid.yml"))).result)[Rails.env].symbolize_keys

    database = if (config[:uri])
      db = URI.parse(config[:uri])
      db_name = db.path.gsub(/^\//, '')
      db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
      db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
      db_connection
    else
      conn = Mongo::Connection.new(config[:host], config[:port])
      conn[config[:database]]
    end

    self.store_procedures!(database)
    database
  end

  # Wrap the args in an anon fuction (hope to make injection a tad harder).
  # Calls it!
  #
  # method_name, arg1, arg2, arg3......
  def self.eval(*args)
    name = args.shift
    arg_names = (1..args.length).map {|i| "a#{i}"}.join(',')
    eval_str = "return function(#{arg_names}) { return #{name}(#{arg_names});}(#{args.map {|v| v.to_json}.join(',')});"
    self.db.eval(eval_str)
  end

  def self.store_procedures!(database = MongoRaw.db)
    Dir[Rails.root.join('db','mongo_procedures', "*")].each do |file|
      name = File.basename(file)
      contents = File.read(file)
      database['system.js'].save({_id:name, value:BSON::Code.new(contents)});
    end
  end
end
