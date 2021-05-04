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

  test "broadcasts a collection (with multi-word class)" do
    with_mocked_renderer do |mock_renderer|
      ActionItem.create description: "Do this"
      ActionItem.create description: "Do that"
      fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", collection: ActionItem.all, extends: :div, locals: {important_local: "needed to render"}) {})

      subscribe

      mock_renderer
        .expect(:render, "<tag></tag>", [partial: "posts/card", locals: {action_item: ActionItem.first, important_local: "needed to render", action_item_counter: 0}])
        .expect(:render, "<tag></tag>", [partial: "posts/card", locals: {action_item: ActionItem.last, important_local: "needed to render", action_item_counter: 1}])

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

    assert_cable_ready_operation_on("Futurism::Channel:1", operation: "outerHtml", selector: "[data-signed-params='#{signed_params}']", html: "3") do
      perform :receive, {"signed_params" => [signed_params]}
    end
  end

  test "broadcasts a correctly formed path" do
    post = Post.create title: "Lorem"
    fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", locals: {post: post}, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe(channel: "Futurism::Channel")

    assert_cable_ready_operation_on("Futurism::Channel:1", operation: "outerHtml",
                                                           selector: "[data-signed-params='#{signed_params}']",
                                                           html: "<div class=\"card\">\n  Lorem\n  <a href=\"/posts/1/edit\">Edit</a>\n</div>\n") do
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

  test "renders error message when rendering invalid partial error" do
    fragment = Nokogiri::HTML.fragment(futurize(partial: "INVALID/PARTIAL", extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe(channel: "Futurism::Channel")

    assert_cable_ready_operation_on("Futurism::Channel:1", operation: "outerHtml",
                                                           selector: "[data-signed-params='#{signed_params}']",
                                                           html: /Missing partial INVALID\/_PARTIAL/) do
      perform :receive, {"signed_params" => [signed_params]}
    end
  end

  test "renders error message when wrong variable name" do
    Post.create title: "Lorem"
    fragment = Nokogiri::HTML.fragment(futurize(partial: "posts/card", collection: Post.all, as: :wrong_variable_name, extends: :div) {})
    signed_params = fragment.children.first["data-signed-params"]
    subscribe(channel: "Futurism::Channel")

    assert_cable_ready_operation_on("Futurism::Channel:1", operation: "outerHtml",
                                                           selector: "[data-signed-params='#{signed_params}']",
                                                           html: /undefined local variable or method/) do
      perform :receive, {"signed_params" => [signed_params]}
    end
  end

  def assert_cable_ready_operation_on(stream, operation:, selector:, html:, &block)
    data = {
      "cableReady" => true,
      "operations" => {
        operation => [{
          "selector" => selector,
          "html" => html
        }]
      }
    }

    old_messages = broadcasts(stream)
    clear_messages(stream)

    assert_nothing_raised(&block)

    new_messages = broadcasts(stream)
    clear_messages(stream)

    # Restore all sent messages
    (old_messages + new_messages).each { |m| pubsub_adapter.broadcast(stream, m) }

    message = new_messages.find { |msg| cableReadyMatch?(operation, ActiveSupport::JSON.decode(msg), data) }

    assert message, "No messages sent with #{data} to #{stream}"
  end

  def cableReadyMatch?(operation, message, matcher)
    return true if message == matcher

    first_matching_operation = ["operations", operation, 0]

    matcher_operation = matcher.dig(*first_matching_operation)
    message_operation = message.dig(*first_matching_operation)

    message.dig("cableReady") == true &&
      (matcher_operation.dig("selector") === message_operation.dig("selector") ||
        matcher_operation.dig("selector").match(message_operation.dig("selector"))) &&
      (matcher_operation.dig("html") === message_operation.dig("html") ||
        matcher_operation.dig("html").match(message_operation.dig("html")))
  end
end
