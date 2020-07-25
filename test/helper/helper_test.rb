require "test_helper"

class Futurism::HelperTest < ActionView::TestCase
  include Futurism::Helpers

  test "renders html options" do
    post = Post.create title: "Lorem"

    assert_dom_equal %{<futurism-element class="absolute inset-0" data-signed-params="#{futurism_signed_params(post)}"></futurism-element>}, futurize(post, extends: :div, html_options: {class: "absolute inset-0"}) {}

    params = {partial: "posts/card", locals: {post: post}}
    assert_dom_equal %{<futurism-element class="flex justify-center" data-signed-params="#{futurism_signed_params(**params)}"></futurism-element>}, futurize(params.merge({html_options: {class: "flex justify-center"}, extends: :div})) {}
  end
end
