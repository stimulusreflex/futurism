require "test_helper"

class Futurism::Test < ActiveSupport::TestCase
  test "component is a ViewComponent" do
    assert_includes NoArgumentComponent.ancestors, ViewComponent::Base
    assert_includes SimpleArgumentComponent.ancestors, ViewComponent::Base
    assert_includes ComplexArgumentComponent.ancestors, ViewComponent::Base
  end

  test "component instance responds to #to_futurism_serialized" do
    instance = NoArgumentComponent.new
    assert_respond_to instance, :to_futurism_serialized
  end

  test "component instance saves no arguments" do
    instance = NoArgumentComponent.new

    assert_respond_to instance, :to_futurism_serialized
    assert_equal instance.instance_variable_get("@raw_initialization_arguments"), []
    assert_equal instance.to_futurism_serialized, [].to_json
  end

  test "component instance saves simple arguments" do
    instance = SimpleArgumentComponent.new(false, "/to/somewhere")

    assert_respond_to instance, :to_futurism_serialized
    assert_equal instance.instance_variable_get("@raw_initialization_arguments"), [false, "/to/somewhere"]
    assert_equal instance.to_futurism_serialized, [false, "/to/somewhere"].to_json
  end

  test "component instance saves complex arguments" do
    post = Post.create title: "Lorem"
    instance = ComplexArgumentComponent.new(false, "/to/somewhere", deactivate: "Deactivate!", active: "Activate!", ar_object: post)

    assert_respond_to instance, :to_futurism_serialized
    assert_equal instance.instance_variable_get("@raw_initialization_arguments"), [false, "/to/somewhere", deactivate: "Deactivate!", active: "Activate!", ar_object: post]
    assert_equal instance.to_futurism_serialized, [false, "/to/somewhere", deactivate: "Deactivate!", active: "Activate!", ar_object: post.to_global_id.to_s].to_json
  end
end

class NoArgumentComponent < ViewComponent::Base
  def call
    link_to active? ? "Deactivate" : "Activate", "/to/somewhere"
  end

  def active?
    [true, false].sample
  end
end

class SimpleArgumentComponent < ViewComponent::Base
  def initialize(active, path)
    @active, @path = active, path
  end

  def call
    link_to active ? "Deactivate" : "Activate", path
  end

  attr_reader :active, :path
end

class ComplexArgumentComponent < ViewComponent::Base
  def initialize(active, path, decativate: "Deactivate", activate: "Activate", **others)
    @active, @path = active, path
    @deactivate = decativate
    @activate = activate
    @others = others
  end

  def call
    link_to active ? "Deactivate" : "Activate", path
  end

  attr_reader :active, :path, :deactivate, :activate, :others
end
