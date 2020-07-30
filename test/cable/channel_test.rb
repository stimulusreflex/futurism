require "test_helper"

class Futurism::ChannelTest < ActionCable::Channel::TestCase
  include Futurism::Helpers
  include ActionView::Helpers
  include ActionView::Context
  include CableReady::Broadcaster

  setup do
    stub_connection(env: {"SCRIPT_NAME" => "/cable"})
  end

  test "subscribed" do
    subscribe

    assert subscription.confirmed?

    assert_has_stream "Futurism::Channel"
  end

  test "broadcasts a rendered model after receiving signed params" do
    renderer_spy = Spy.on(ApplicationController, :render)
    post = Post.create title: "Lorem"
    fragment = Nokogiri::HTML.fragment(futurize(post, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    perform :receive, {"signed_params" => [signed_params]}

    assert renderer_spy.has_been_called_with? post
  end

  test "broadcasts an ActiveRecord::Relation" do
    renderer_spy = Spy.on(ApplicationController, :render)
    Post.create title: "Lorem"
    Post.create title: "Ipsum"
    fragment = Nokogiri::HTML.fragment(futurize(Post.all, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    perform :receive, {"signed_params" => [signed_params]}

    signed_params = fragment.children.last["data-signed-params"]
    perform :receive, {"signed_params" => [signed_params]}

    assert renderer_spy.has_been_called_with? Post.first
    assert renderer_spy.has_been_called_with? Post.last
  end

  test "broadcasts a rendered partial after receiving signed params" do
    renderer_spy = Spy.on(ApplicationController, :render)
    post = Post.create title: "Lorem"
    fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", locals: {post: post}, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    perform :receive, {"signed_params" => [signed_params]}

    assert renderer_spy.has_been_called_with?(partial: "posts/card", locals: {post: post})
  end

  test "broadcasts a rendered partial after receiving the shorthand syntax" do
    renderer_spy = Spy.on(ApplicationController, :render)
    post = Post.create title: "Lorem"
    fragment = Nokogiri::HTML.fragment(futurize("posts/card", post: post, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    perform :receive, {"signed_params" => [signed_params]}

    assert renderer_spy.has_been_called_with?(partial: "posts/card", locals: {post: post})
  end

  test "broadcasts a collection" do
    renderer_spy = Spy.on(ApplicationController, :render)
    Post.create title: "Lorem"
    Post.create title: "Ipsum"
    fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", collection: Post.all, extends: :div, locals: {important_local: "needed to render"}) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    perform :receive, {"signed_params" => [signed_params]}

    signed_params = fragment.children.last["data-signed-params"]
    perform :receive, {"signed_params" => [signed_params]}

    assert renderer_spy.has_been_called_with?(partial: "posts/card", locals: {post: Post.first, important_local: "needed to render"})
    assert renderer_spy.has_been_called_with?(partial: "posts/card", locals: {post: Post.last, important_local: "needed to render"})
  end

  test "broadcasts a collection with :as" do
    renderer_spy = Spy.on(ApplicationController, :render)
    Post.create title: "Lorem"
    Post.create title: "Ipsum"
    fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", collection: Post.all, as: :post_item, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    perform :receive, {"signed_params" => [signed_params]}

    signed_params = fragment.children.last["data-signed-params"]
    perform :receive, {"signed_params" => [signed_params]}

    assert renderer_spy.has_been_called_with?(partial: "posts/card", locals: {post_item: Post.first})
    assert renderer_spy.has_been_called_with?(partial: "posts/card", locals: {post_item: Post.last})
  end

  test "broadcasts an inline rendered text" do
    fragment = Nokogiri::HTML.fragment(futurize(inline: "<%= 1 + 2 %>", extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    assert_broadcast_on("Futurism::Channel", "cableReady" => true, "operations" => {"outerHtml" => [{"selector" => "[data-signed-params='#{signed_params}']", "html" => "3"}]}) do
      perform :receive, {"signed_params" => [signed_params]}
    end
  end

  test "broadcasts a correctly formed path" do
    post = Post.create title: "Lorem"
    fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", locals: {post: post}, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe

    assert_broadcast_on("Futurism::Channel", "cableReady" => true, "operations" => {"outerHtml" => [{"selector" => "[data-signed-params='#{signed_params}']", "html" => "<div class=\"card\">\n  Lorem\n  <a href=\"/posts/1/edit\">Edit</a>\n</div>\n"}]}) do
      perform :receive, {"signed_params" => [signed_params]}
    end
  end
end
