require 'machinist/mongo_mapper' # or mongoid

CollectorWorker.blueprint do
  url { "http://#{sn}.collector.com" }
end
AccessToken.blueprint do
  key    { "test_key_#{sn}" }
  user_application { UserApplication.make! }
end
Deployment.blueprint do
  commit_id   { "commit_#{sn}" }
  commit_info { {'name' => 'test_commit', 'description' => 'foo'} }
  user_application { UserApplication.make! }
end
UserApplication.blueprint do
  name { "#{sn}_application"}
end
