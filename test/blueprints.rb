require 'machinist/active_record'

CollectorWorker.blueprint do
  url { "http://#{sn}.collector.com" }
end
AccessToken.blueprint do
  secret { 'test_secret' }
  key    { 'test_key' }
end
