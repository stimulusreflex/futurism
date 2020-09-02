require "test_helper"

class Futurism::HelperTest < ActionView::TestCase
  include Futurism::Helpers

  test "renders html options with data attributes" do
    post = Post.create title: "Lorem"

    element = Nokogiri::HTML.fragment(futurize(post, extends: :div, html_options: {class: "absolute inset-0", data: {controller: "test"}}) {})

    assert_equal "futurism-element", element.children.first.name
    assert_equal post, GlobalID::Locator.locate_signed(element.children.first["data-sgid"])
    assert_equal signed_params({data: {controller: "test"}}), element.children.first["data-signed-params"]
    assert_equal "absolute inset-0", element.children.first["class"]

    params = {partial: "posts/card", locals: {post: post}}
    element = Nokogiri::HTML.fragment(futurize(params.merge({html_options: {class: "flex justify-center", data: {action: "test#click"}}, extends: :div})) {})

    assert_equal "futurism-element", element.children.first.name
    assert_nil element.children.first["data-sgid"]
    assert_equal signed_params(params.merge({data: {action: "test#click"}})), element.children.first["data-signed-params"]
    assert_equal "flex justify-center", element.children.first["class"]
  end

  def signed_params(params)
    Rails.application.message_verifier("futurism").generate(params)
  end
end
