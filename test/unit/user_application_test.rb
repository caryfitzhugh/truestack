require 'test_helper'

class UserApplicationTest < ActiveSupport::TestCase
  test "we can create an app and push in some request data" do
    application = UserApplication.make!
    application.add_request("Controller#action",
      {
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
        ]
      }
    )

  end

  test "user app has access_tokens" do
    app = UserApplication.make!

    assert_equal 1, app.access_tokens.length
  end
end
