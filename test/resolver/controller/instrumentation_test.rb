require "test_helper"

class DummyController < ActionController::Base
  def name_helper
    "FUTURISM".freeze
  end
  helper_method :name_helper

  def controller_and_action_helper
    [params["controller"], params["action"]].join(":")
  end
  helper_method :controller_and_action_helper

  def name_from_params_helper
    params["name"]
  end
  helper_method :name_from_params_helper
end

def dummy_connection
  connection = Minitest::Mock.new
  connection.expect(:env, {"HTTP_VAR" => "HTTP_VAR_VALUE"})
  connection
end

class Futurism::Resolver::Controller::InstrumentationTest < ActiveSupport::TestCase
  test "invokes ActiveSupport instrumentation on the Futurism render" do
    swap Futurism, instrumentation: true do
      events = []
      ActiveSupport::Notifications.subscribe("render.futurism") do |*args|
        events << ActiveSupport::Notifications::Event.new(*args)
      end

      renderer = Futurism::Resolver::Controller::Renderer.for(
        controller: DummyController,
        connection: dummy_connection,
        url: "posts/1",
        params: {channel: "Futurism::Channel"}
      )
      post = Post.create title: "Lorem"
      renderer.render(partial: "posts/card", locals: {post: post})

      assert_equal 1, events.size
      assert_equal "render.futurism", events.last.name
      assert_equal "Futurism::Channel", events.last.payload[:channel]
      assert_equal "posts", events.last.payload[:controller]
      assert_equal "show", events.last.payload[:action]
      assert_equal "posts/card", events.last.payload[:partial]
    end
  end

  test "does not invoke ActiveSupport instrumentation by default" do
    events = []
    ActiveSupport::Notifications.subscribe("render.futurism") do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end

    renderer = Futurism::Resolver::Controller::Renderer.for(
      controller: DummyController,
      connection: dummy_connection,
      url: "posts/1",
      params: {channel: "Futurism::Channel"}
    )
    post = Post.create title: "Lorem"
    renderer.render(partial: "posts/card", locals: {post: post})

    assert_empty events
  end
end
