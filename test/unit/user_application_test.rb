require 'test_helper'

class UserApplicationTest < ActiveSupport::TestCase
  test "we can create an app and attach deployments" do
    application = UserApplication.make!
    new_deployment = application.deploy!(:commit_id=>"git-commit-id",
        'free-form'=>'commit-information',
        :all_actions => ['method#one', 'method#two'])
    assert_equal new_deployment, application.latest_deployment
  end
  test "we can create an app and push in some request data" do
    application = UserApplication.make!
    application.add_request("Controller#action", "1111",
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
  test "latest deployment is correctly found" do
    application = UserApplication.make!
    Deployment.make!(:created_at => 0, :user_application => application)
    latest = Deployment.make!(:created_at => 1, :user_application => application)

    assert_equal latest, application.latest_deployment
  end

  test "user app has access_tokens" do
    app = UserApplication.make!

    assert_equal 1, app.access_tokens.length
  end
end
