require 'machinist/mongo_mapper' # or mongoid

CollectorWorker.blueprint do
  url { "http://#{sn}.collector.com" }
end
AccessToken.blueprint do
  secret { 'test_secret' }
  key    { 'test_key' }
  user_application { UserApplication.make! }
end
Deployment.blueprint do

end
UserApplication.blueprint do
  name { "#{sn}_application"}
end
