require "test_helper"

class DummyController < ActionController::Base; end

class Futurism::Resolver::ControllerTest < ActiveSupport::TestCase
  test ".from defaults to ApplicationController" do
    controller = Futurism::Resolver::Controller.from(signed_string: nil)
    assert_equal controller, ApplicationController
  end

  test ".from uses Futurism.default_controller" do
    swap Futurism, default_controller: DummyController do
      controller = Futurism::Resolver::Controller.from(signed_string: nil)

      assert_equal controller, DummyController
    end
  end

  test ".from lookups up controller via signed_string:" do
    signed_controller_string = Futurism::MessageVerifier.message_verifier.generate(DummyController.to_s)
    controller = Futurism::Resolver::Controller.from(signed_string: signed_controller_string)

    assert_equal controller, DummyController
  end
end
