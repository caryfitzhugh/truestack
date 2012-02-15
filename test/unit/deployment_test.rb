require 'test_helper'

class DeploymentTest < ActiveSupport::TestCase
  test "we create a deployment and can add some timings to it" do
    deployment = Deployment.make!
    # Adding a request involves the action_name and then a hash of method => timing_data sets
    deployment.add_request("myapplication#myaction",
      controller_action: 700.0,
      model_action: 300.3,
      db_request:   200
           )
    deployment.save!

    assert_equal 700, deployment.application_actions.get('controller_action').mean
    assert_equal 1, deployment.application_actions.get('controller_action').count
    assert_equal 0, deployment.application_actions.get('controller_action').square
    assert_equal 0, deployment.application_actions.get('controller_action').stddev
  end

  test "we create the deployment and it tracks mean " do
    deployment = Deployment.make!
    # Adding a request involves the action_name and then a hash of method => timing_data sets
    deployment.add_request("myapplication#myaction", action: 10.0)
    deployment.add_request("myapplication#myaction", action: 10.0)
    deployment.add_request("myapplication#myaction", action: 10.0)
    deployment.add_request("myapplication#myaction", action: 10.0)
    deployment.add_request("myapplication#myaction", action: 10.0)
    deployment.save!
    assert_equal 10, deployment.application_actions.get(:action).mean
    assert_equal 5,  deployment.application_actions.get(:action).count
    assert_equal 0,  deployment.application_actions.get(:action).square
  end

  test "we create the deployment and it tracks stddev " do
    deployment = Deployment.make!
    # Adding a request involves the action_name and then a hash of method => timing_data sets
    deployment.add_request("myapplication#myaction", action: 11.0)
    deployment.add_request("myapplication#myaction", action: 9.0)
    deployment.save!

    assert_equal 10, deployment.application_actions.get('action').mean
    assert_equal 2,  deployment.application_actions.get('action').stddev
    assert_equal 2,  deployment.application_actions.get('action').count
  end

end
