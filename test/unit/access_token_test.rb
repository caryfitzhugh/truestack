require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase
  test "create one and grab it's application" do
    token = AccessToken.make!
    token.user_application.latest_deployment
  end
end
