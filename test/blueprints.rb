require 'machinist/mongo_mapper' # or mongoid

CollectorWorker.blueprint do
  url { "http://#{sn}.collector.com" }
end
AccessToken.blueprint do
  key    { "test_key_#{sn}" }
  user_application { UserApplication.make! }
end

UserApplication.blueprint do
  name { "#{sn}_application"}
end

User.blueprint do
  email { "#{sn}@gmail.com" }
  password { "password" }
  password_confirmation { object.password }
  first_name {"First#{sn}" }
  last_name  {"Last#{sn}" }
end
