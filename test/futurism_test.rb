require "test_helper"

class DummyController < ActionController::Base; end

class Futurism::Test < ActiveSupport::TestCase
  test "module" do
    assert_kind_of Module, Futurism
  end

  test ".skip_in_test" do
    assert_equal false, Futurism.skip_in_test
  end

  test ".default_controller" do
    assert_equal ApplicationController, Futurism.default_controller

    Futurism.default_controller = nil
    assert_equal ApplicationController, Futurism.default_controller

    Futurism.default_controller = DummyController
    assert_equal DummyController, Futurism.default_controller

    Futurism.default_controller = "DummyController"
    assert_equal DummyController, Futurism.default_controller

    Futurism.default_controller = nil
  end
end
