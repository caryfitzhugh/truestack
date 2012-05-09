require 'test_helper'

class CallTreeTest < ActiveSupport::TestCase
  test "create a tree" do
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
    tree = CallTree.new("controller#action", methods)
  end
end
