require 'test_helper'

class CallTreeTest < ActiveSupport::TestCase
  test "create a tree" do
    now = Time.now.to_f * 1000
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
    tree = CallTree.new("controller#action", methods)
    tree.for_each do |v|
      pp v
    end
  end
end
