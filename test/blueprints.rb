require 'machinist/active_record'

CollectorWorker.blueprint do
  url { "http://#{sn}.collector.com" }
end
