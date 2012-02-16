require 'machinist/mongo_mapper' # or mongoid

CollectorWorker.blueprint do
  url { "http://#{sn}.collector.com" }
end
AccessToken.blueprint do
  secret { "test_secret_#{sn}" }
  key    { "test_key_#{sn}" }
  user_application { UserApplication.make! }
end
Deployment.blueprint do
  commit_id   { "commit_#{sn}" }
  commit_info { {'name' => 'test_commit', 'description' => 'foo'} }
  user_application { UserApplication.make! }
end
ApplicationAction.blueprint do
  name { "action_#{sn}" }
end
UserApplication.blueprint do
  name { "#{sn}_application"}
end
