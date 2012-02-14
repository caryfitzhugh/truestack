require 'test_helper'

class UserApplicationTest < ActiveSupport::TestCase
  test "we can create an app and attach deployments" do
    application = UserApplication.make!
    new_deployment = application.deployed!("git-commit-id", {'free-form'=>'commit-information'}, ['method#one', 'method#two'])
    assert_equal new_deployment, application.latest_deployment
  end

  test "latest deployment is correctly found" do
    application = UserApplication.make!
    Deployment.make!(:created_at => 0, :user_application => application)
    latest = Deployment.make!(:created_at => 1, :user_application => application)

    assert_equal latest, application.latest_deployment
  end
end
