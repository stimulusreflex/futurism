require "test_helper"

class DummyController < ActionController::Base; end

class Futurism::Test < ActiveSupport::TestCase
  test "module" do
    assert_kind_of Module, Futurism
  end

  test ".skip_in_test?" do
    swap Futurism, skip_in_test: "" do
      assert_equal false, Futurism.skip_in_test?
    end
  end

  test ".instrumentation?" do
    swap Futurism, instrumentation: "" do
      assert_equal false, Futurism.instrumentation?
    end
  end

  test ".default_controller" do
    assert_equal ApplicationController, Futurism.default_controller

    swap Futurism, default_controller: nil do
      assert_equal ApplicationController, Futurism.default_controller
    end

    swap Futurism, default_controller: DummyController do
      assert_equal DummyController, Futurism.default_controller
    end

    swap Futurism, default_controller: "DummyController" do
      assert_equal DummyController, Futurism.default_controller
    end
  end
end
