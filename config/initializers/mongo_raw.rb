require 'mongo'

module MongoRaw
  def self.db
    @db ||= self.connect!
  end
  def self.connect!
    config = YAML.load_file("#{Rails.root}/config/mongoid.yml")[Rails.env]
    if (config[:uri])
      conn = Mongo::Connection.from_uri(config[:uri])
      conn.db(URI.parse(config[:uri]).path.gsub(/^\//, ''))
    else
      conn = Mongo::Connection.new(config[:host], config[:port])
      conn[config[:database]]
    end
  end
end
