require 'test_helper'

class TimeSliceTest < ActiveSupport::TestCase
  test "do create a single time slice" do
    now = (Time.now.to_f * 1000).round
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
    TimeSlice.add_request('app_id', 'deploy:123', 'controller#action', methods)
  end
end
