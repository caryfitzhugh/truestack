require 'test_helper'

class DeploymentTest < ActiveSupport::TestCase
  test "req per second results" do
    deployment = Deployment.make!
    deployment.add_request("one", {action: {s:0, d:700}})
    deployment.add_request("one", {action: {s:0, d:700}})
    deployment.add_request("one", {action: {s:0, d:700}})
    deployment.add_request("one", {action: {s:0, d:700}})
    deployment.add_request("one", {action: {s:0, d:700}})
    deployment.add_request("two", {action: {s:0, d:700}})
    deployment.add_request("two", {action: {s:0, d:700}})
    deployment.add_request("two", {action: {s:0, d:700}})
    deployment.add_request("two", {action: {s:0, d:700}})
    deployment.add_request("two", {action: {s:0, d:700}})

    assert_equal 10.0 / 2, deployment.req_per_second((deployment.created_at + 2))
  end

  test "we create a deployment and can add some timings to it" do
    deployment = Deployment.make!
    # Adding a request involves the action_name and then a hash of method => timing_data sets
    deployment.add_request("myapplication#myaction",
      controller_action: {s: 700.0, d: 700},
      model_action: {s: 0, d: 300.3},
      db_request:   {s: 40, d: 200}
           )
    deployment.save!

    assert_equal 700, deployment.application_actions.get('controller_action').duration_mean
    assert_equal 1, deployment.application_actions.get('controller_action').count
    assert_equal 0, deployment.application_actions.get('controller_action').duration_square
    assert_equal 0, deployment.application_actions.get('controller_action').duration_stddev
  end

  test "we create the deployment and it tracks mean " do
    deployment = Deployment.make!
    # Adding a request involves the action_name and then a hash of method => timing_data sets
    deployment.add_request("myapplication#myaction", action: {s:0, d:10})
    deployment.add_request("myapplication#myaction", action: {s:0, d:10})
    deployment.add_request("myapplication#myaction", action: {s:0, d:10})
    deployment.add_request("myapplication#myaction", action: {s:0, d:10})
    deployment.add_request("myapplication#myaction", action: {s:0, d:10})
    deployment.save!
    assert_equal 10, deployment.application_actions.get(:action).duration_mean
    assert_equal 5,  deployment.application_actions.get(:action).count
    assert_equal 0,  deployment.application_actions.get(:action).duration_square
  end

  test "we create the deployment and it tracks stddev " do
    deployment = Deployment.make!
    # Adding a request involves the action_name and then a hash of method => timing_data sets
    deployment.add_request("myapplication#myaction", action: {s: 9.0, d: 11.0})
    deployment.add_request("myapplication#myaction", action: {s: 11.0, d: 9.0})
    deployment.save!

    assert_equal 10, deployment.application_actions.get('action').duration_mean
    assert_equal 2,  deployment.application_actions.get('action').duration_stddev
    assert_equal 10, deployment.application_actions.get('action').start_mean
    assert_equal 2,  deployment.application_actions.get('action').start_stddev
    assert_equal 2,  deployment.application_actions.get('action').count
  end
end
