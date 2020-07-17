require "test_helper"

class Futurism::ChannelTest < ActionCable::Channel::TestCase
  include Futurism::Helpers

  test "subscribed" do
    subscribe

    assert subscription.confirmed?

    assert_has_stream "Futurism::Channel"
  end

  test "broadcasts a rendered model after receiving signed params" do
    renderer_spy = Spy.on(ApplicationController, :render)
    post = Post.create title: "Lorem"
    signed_params = futurism_signed_params(post)
    subscribe

    perform :receive, {"signed_params" => [signed_params]}

    assert renderer_spy.has_been_called_with? post
  end
end
