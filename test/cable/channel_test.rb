require "test_helper"

def with_mocked_renderer
  renderer = Minitest::Mock.new

  Futurism::Resolver::Controller::Renderer.stub(:for, renderer) do
    yield(renderer)
  end
end

class Futurism::ChannelTest < ActionCable::Channel::TestCase
  include Futurism::Helpers
  include ActionView::Helpers
  include ActionView::Context
  include CableReady::Broadcaster

  setup do
    stub_connection(env: {"SCRIPT_NAME" => "/cable"}, identifiers: [:current_user], current_user: Struct.new(:id)[1])
  end

  test "subscribed" do
    subscribe(channel: "Futurism::Channel")

    assert subscription.confirmed?

    assert_has_stream "Futurism::Channel:1"
  end

  test "broadcasts a rendered model after receiving signed params" do
    with_mocked_renderer do |mock_renderer|
      post = Post.create title: "Lorem"
      fragment = Nokogiri::HTML.fragment(futurize(post, extends: :div) {})
      signed_params_array = fragment.children.map { |element| element["data-signed-params"] }
      sgids = fragment.children.map { |element| element["data-sgid"] }
      subscribe

      mock_renderer.expect :render, "<tag></tag>", [post]

      perform :receive, {"signed_params" => signed_params_array, "sgids" => sgids}

      assert_mock mock_renderer
    end
  end

  test "broadcasts an ActiveRecord::Relation" do
    with_mocked_renderer do |mock_renderer|
      post1 = Post.create(title: "Lorem")
      post2 = Post.create(title: "Ipsum")

      fragment = Nokogiri::HTML.fragment(futurize(Post.all, extends: :div) {})
      signed_params_array = fragment.children.map { |element| element["data-signed-params"] }
      sgids = fragment.children.map { |element| element["data-sgid"] }
      subscribe

      mock_renderer
        .expect(:render, "<tag></tag>", [post1])
        .expect :render, "<tag></tag>", [post2]

      perform :receive, {"signed_params" => signed_params_array, "sgids" => sgids}

      assert_mock mock_renderer
    end
  end

  test "broadcasts a rendered partial after receiving signed params" do
    with_mocked_renderer do |mock_renderer|
      post = Post.create title: "Lorem"
      fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", locals: {post: post}, extends: :div) {})
      signed_params = fragment.children.first["data-signed-params"]
      subscribe

      mock_renderer
        .expect(:render, "<tag></tag>", [partial: "posts/card", locals: {post: post}])

      perform :receive, {"signed_params" => [signed_params]}

      assert_mock mock_renderer
    end
  end

  test "broadcasts a rendered partial after receiving the shorthand syntax" do
    with_mocked_renderer do |mock_renderer|
      post = Post.create title: "Lorem"
      fragment = Nokogiri::HTML.fragment(futurize("posts/card", post: post, extends: :div) {})
      signed_params = fragment.children.first["data-signed-params"]
      subscribe

      mock_renderer.expect(:render, "<tag></tag>", [partial: "posts/card", locals: {post: post}])
      perform :receive, {"signed_params" => [signed_params]}

      assert_mock mock_renderer
    end
  end

  test "broadcasts a rendered partial after receiving the shorthand syntax with html options" do
    with_mocked_renderer do |mock_renderer|
      post = Post.create title: "Lorem"
      fragment = Nokogiri::HTML.fragment(futurize("posts/card", post: post, extends: :div, html_options: {style: "color: green"}) {})
      signed_params = fragment.children.first["data-signed-params"]
      subscribe

      mock_renderer.expect(:render, "<tag></tag>", [partial: "posts/card", locals: {post: post}])

      perform :receive, {"signed_params" => [signed_params]}

      assert_mock mock_renderer
    end
  end

  test "broadcasts a collection" do
    with_mocked_renderer do |mock_renderer|
      Post.create title: "Lorem"
      Post.create title: "Ipsum"
      fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", collection: Post.all, extends: :div, locals: {important_local: "needed to render"}) {})
      subscribe

      mock_renderer
        .expect(:render, "<tag></tag>", [partial: "posts/card", locals: {post: Post.first, important_local: "needed to render", post_counter: 0}])
        .expect(:render, "<tag></tag>", [partial: "posts/card", locals: {post: Post.last, important_local: "needed to render", post_counter: 1}])

      signed_params = fragment.children.first["data-signed-params"]
      perform :receive, {"signed_params" => [signed_params]}

      signed_params = fragment.children.last["data-signed-params"]
      perform :receive, {"signed_params" => [signed_params]}

      assert_mock mock_renderer
    end
  end

  test "broadcasts a collection with :as" do
    with_mocked_renderer do |mock_renderer|
      Post.create title: "Lorem"
      Post.create title: "Ipsum"
      fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", collection: Post.all, as: :post_item, extends: :div) {})
      subscribe

      mock_renderer.expect(:render, "<tag></tag>", [partial: "posts/card", locals: {post_item: Post.first, post_item_counter: 0}])
      signed_params = fragment.children.first["data-signed-params"]
      perform :receive, {"signed_params" => [signed_params]}

      mock_renderer.expect(:render, "<tag></tag>", [partial: "posts/card", locals: {post_item: Post.last, post_item_counter: 1}])
      signed_params = fragment.children.last["data-signed-params"]
      perform :receive, {"signed_params" => [signed_params]}

      assert_mock mock_renderer
    end
  end

  test "broadcasts an inline rendered text" do
    fragment = Nokogiri::HTML.fragment(futurize(inline: "<%= 1 + 2 %>", extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe(channel: "Futurism::Channel")

    assert_broadcast_on("Futurism::Channel:1", "cableReady" => true, "operations" => {"outerHtml" => [{"selector" => "[data-signed-params='#{signed_params}']", "html" => "3"}]}) do
      perform :receive, {"signed_params" => [signed_params]}
    end
  end

  test "broadcasts a correctly formed path" do
    post = Post.create title: "Lorem"
    fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", locals: {post: post}, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe(channel: "Futurism::Channel")

    assert_broadcast_on("Futurism::Channel:1", "cableReady" => true, "operations" => {"outerHtml" => [{"selector" => "[data-signed-params='#{signed_params}']", "html" => "<div class=\"card\">\n  Lorem\n  <a href=\"/posts/1/edit\">Edit</a>\n</div>\n"}]}) do
      perform :receive, {"signed_params" => [signed_params]}
    end
  end

  test "passes parsed params to controller render" do
    with_mocked_renderer do |mock_renderer|
      post = Post.create title: "Lorem"
      fragment = Nokogiri::HTML.fragment(futurize(post, extends: :div) {})
      signed_params_array = fragment.children.map { |element| element["data-signed-params"] }
      sgids = fragment.children.map { |element| element["data-sgid"] }
      urls = Array.new(fragment.children.length, "http://www.example.org/route?param1=true&param2=1234")
      subscribe

      mock_renderer.expect(:render, "<tag></tag>", [post])

      perform :receive, {"signed_params" => signed_params_array, "sgids" => sgids, "urls" => urls}

      assert_mock mock_renderer
    end
  end
end
