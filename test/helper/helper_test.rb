require "test_helper"

class Futurism::HelperTest < ActionView::TestCase
  include Futurism::Helpers

  test "renders html options with data attributes" do
    post = Post.create title: "Lorem"

    element = Nokogiri::HTML.fragment(futurize(post, extends: :div, html_options: {class: "absolute inset-0", data: {controller: "test"}}) {})

    assert_equal "futurism-element", element.children.first.name
    assert_equal post, GlobalID::Locator.locate_signed(element.children.first["data-sgid"])
    assert_equal signed_params({data: {controller: "test"}}), element.children.first["data-signed-params"]
    assert_nil element.children.first["data-eager"]
    assert_equal "absolute inset-0", element.children.first["class"]

    params = {partial: "posts/card", locals: {post: post}}
    element = Nokogiri::HTML.fragment(futurize(params.merge({html_options: {class: "flex justify-center", data: {action: "test#click"}}, extends: :div})) {})

    assert_equal "futurism-element", element.children.first.name
    assert_nil element.children.first["data-sgid"]
    assert_nil element.children.first["data-eager"]
    assert_equal signed_params(params.merge({data: {action: "test#click"}})), element.children.first["data-signed-params"]
    assert_equal "flex justify-center", element.children.first["class"]
  end

  test "ensures signed_params and sgid are not overwritable" do
    post = Post.create title: "Lorem"

    element = Nokogiri::HTML.fragment(futurize(post, extends: :div, html_options: {data: {controller: "test", sgid: "test", signed_params: "test"}}) {})

    assert_equal post, GlobalID::Locator.locate_signed(element.children.first["data-sgid"])
    assert_equal signed_params({data: {controller: "test"}}), element.children.first["data-signed-params"]
  end

  test "allows to specify a new record" do
    post = Post.new

    element = Nokogiri::HTML.fragment(futurize("posts/form", post: post, extends: :div) {})

    assert resource(signed_params: element.children.first["data-signed-params"], sgid: nil)[:locals][:post].new_record?
  end

  test "renders an eager loading data attribute" do
    post = Post.create title: "Lorem"

    element = Nokogiri::HTML.fragment(futurize(post, extends: :div, eager: true) {})

    assert_equal "true", element.children.first["data-eager"]

    element = Nokogiri::HTML.fragment(futurize(partial: "posts/card", locals: {post: post}, eager: true, extends: :div) {})
    assert_equal "true", element.children.first["data-eager"]
  end

  def signed_params(params)
    Rails.application.message_verifier("futurism").generate(transformed_options(params))
  end

  def transformed_options(options)
    options.deep_transform_values do |value|
      value.is_a?(ActiveRecord::Base) && !value.new_record? ? value.to_global_id.to_s : value
    end
  end

  def resource(signed_params:, sgid:)
    return GlobalID::Locator.locate_signed(sgid) if sgid.present?

    Rails
      .application
      .message_verifier("futurism")
      .verify(signed_params)
      .deep_transform_values { |value| value.is_a?(String) && value.start_with?("gid://") ? GlobalID::Locator.locate(value) : value }
  end
end
