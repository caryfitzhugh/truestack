require 'test_helper'

class TimeSliceTest < ActiveSupport::TestCase
  test "do create a single time slice" do
    methods = {
        'klass#method1' => [{
          tstart: 0,
          tend:   10
        }],
        'klass#method2' => [
          {
            tstart: 0,
            tend:   4
          },
          {
            tstart: 5,
            tend:   10
          }
        ],
        "klass#method3" => [
          { tstart: 2, tend: 3 },
          { tstart: 8, tend: 9 }
        ],
        "klass#method4" => [
          { tstart: 8, tend: 9 }
        ]
      }
    TimeSlice.add_request('app_id', 'deploy:123', 'controller#action', methods)
  end
end
