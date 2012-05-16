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

def mock_actions(now = (Time.now.to_f * 1000).to_i)
    methods = {
        'klass#method1' => [{
          tstart: now,
          tend:   now + 10 * 1000
        }],
        'klass#method2' => [
          {
            tstart: now,
            tend:   now + 4 * 1000
          },
          {
            tstart: now + 5 * 1000,
            tend:   now + 10 * 1000
          }
        ],
        "klass#method3" => [
          { tstart: now + 2000, tend: now + 3000 },
          { tstart: now + 8000, tend: now + 9000 }
        ],
        "klass#method4" => [
          { type: 'model', tstart: now + 8000, tend: now + 9000 }
        ]
      }

end
def mock_methods
  # From truestack_rails
  #self.instrumented_methods << [klass.to_s, method, location.to_s, classification.to_s]
  [ ["klass", "method1", "app/models/klass.rb:33", "model"],
    ["klass", "method2", "app/views/view.rb:22", 'view'],
    ["klass", "method3", "app/helpers/helper.rb:11", "helper"],
    ["klass", 'method4', 'app/controllers/controller.rb:44', 'controller']
  ]
end
