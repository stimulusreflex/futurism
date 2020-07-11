require "test_helper"

class Futurism::ChannelTest < ActionCable::Channel::TestCase
  def test_subscribed
    subscribe

    assert subscription.confirmed?

    assert_has_stream "Futurism::Channel"
  end
end
