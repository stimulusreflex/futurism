require "test_helper"

class Futurism::ChannelTest < ActionCable::Channel::TestCase
  test "subscribed" do
    subscribe

    assert subscription.confirmed?

    assert_has_stream "Futurism::Channel"
  end

  test "broadcasts after receiving sgids" do
    renderer_spy = Spy.on(ApplicationController, :render)
    post = Post.create title: "Lorem"
    sgid = post.to_sgid.to_s
    subscribe

    perform :receive, {"sgids" => [sgid]}

    assert renderer_spy.has_been_called_with? post
  end
end
