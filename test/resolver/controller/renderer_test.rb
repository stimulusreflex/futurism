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

class Futurism::Resolver::Controller::RendererTest < ActiveSupport::TestCase
  test ".for controller configures renderer" do
    renderer = Futurism::Resolver::Controller::Renderer.for(controller: ApplicationController,
                                                            connection: dummy_connection,
                                                            url: "http://www.example.org?someParam=1234",
                                                            params: {"SOME" => "SOME_VALUE"})
    assert_equal renderer.controller, ApplicationController

    assert_equal renderer.render(inline: "<%= request.env['HTTP_VAR'] %>"), "HTTP_VAR_VALUE"
    assert_equal renderer.render(inline: "<%= params['someParam'] %>"), "1234"
    assert_equal renderer.render(inline: "<%= params['SOME'] %>"), "SOME_VALUE"
  end

  test ".for controller configures renderer using the passed in controller" do
    renderer = Futurism::Resolver::Controller::Renderer.for(controller: DummyController,
                                                            connection: dummy_connection,
                                                            url: "http://www.example.org?someParam=1234",
                                                            params: {"SOME" => "SOME_VALUE"})
    assert_equal renderer.controller, DummyController

    assert_equal renderer.render(inline: "<%= request.env['HTTP_VAR'] %>"), "HTTP_VAR_VALUE"
    assert_equal renderer.render(inline: "<%= params['someParam'] %>"), "1234"
    assert_equal renderer.render(inline: "<%= params['SOME'] %>"), "SOME_VALUE"
  end

  test "renderer.render resolves helper methods" do
    renderer = Futurism::Resolver::Controller::Renderer.for(controller: DummyController,
                                                            connection: dummy_connection,
                                                            url: "http://www.example.org?name=the%20future",
                                                            params: {})

    rendered_html = renderer.render(inline: "Hi <%= name_helper %>")

    assert_equal rendered_html, "Hi FUTURISM"
  end

  test "renderer.render resolves helper methods that rely on params from controller" do
    renderer = Futurism::Resolver::Controller::Renderer.for(controller: DummyController,
                                                            connection: dummy_connection,
                                                            url: "http://www.example.org?name=the%20future!",
                                                            params: {"controller" => "home", "action" => "index"})

    rendered_html = renderer.render(inline: "Hi <%= controller_and_action_helper %>")

    assert_equal rendered_html, "Hi home:index"
  end

  test "renderer.render resolves helper methods that rely on params from url" do
    renderer = Futurism::Resolver::Controller::Renderer.for(controller: DummyController,
                                                            connection: dummy_connection,
                                                            url: "http://www.example.org?name=the%20future!",
                                                            params: {})
    rendered_html = renderer.render(inline: "Hi <%= name_from_params_helper %>")

    assert_equal rendered_html, "Hi the future!"
  end
end
