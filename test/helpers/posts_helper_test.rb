# frozen_string_literal: true

require "test_helper"
require "rails_autolink/helpers"

class PostsHelperTest < ActionView::TestCase
  def render_body(body)
    post_body(Post.new(body: body))
  end

  test "keeps the formatting the editor makes" do
    html = render_body('<div><strong>Furr</strong> is <em>great</em><br><a href="https://example.com">link</a></div><blockquote>quote</blockquote><ul><li>one</li></ul>')
    assert_includes html, "<strong>Furr</strong>"
    assert_includes html, "<em>great</em>"
    assert_includes html, '<a href="https://example.com">link</a>'
    assert_includes html, "<blockquote>quote</blockquote>"
    assert_includes html, "<li>one</li>"
  end

  test "keeps image attachments" do
    html = render_body('<figure><img src="https://files.example.com/a.jpg" width="300"><figcaption>Live</figcaption></figure>')
    assert_includes html, '<img src="https://files.example.com/a.jpg" width="300">'
    assert_includes html, "<figcaption>Live</figcaption>"
  end

  test "removes scripts, event handlers and javascript links" do
    html = render_body('<script>alert(1)</script><img src="x.jpg" onerror="alert(2)"><a href="javascript:alert(3)">click</a><style>body{display:none}</style><p style="position:fixed">hi</p>')
    assert_not_includes html, "<script"
    assert_not_includes html, "alert"
    assert_not_includes html, "onerror"
    assert_not_includes html, "<style"
    assert_not_includes html, "position"
    assert_includes html, "click"
    assert_includes html, "hi"
  end

  test "keeps YouTube and Vimeo embeds but drops other iframes and plugins" do
    youtube = '<iframe src="https://www.youtube.com/embed/abc123" width="560" height="315" frameborder="0" allowfullscreen></iframe>'
    vimeo = '<iframe src="https://player.vimeo.com/video/42"></iframe>'
    html = render_body("#{youtube}#{vimeo}<iframe src=\"https://evil.example/\"></iframe><object data=\"x.swf\"></object><embed src=\"x.swf\">")
    assert_includes html, 'src="https://www.youtube.com/embed/abc123"'
    assert_includes html, 'src="https://player.vimeo.com/video/42"'
    assert_not_includes html, "evil.example"
    assert_not_includes html, "<object"
    assert_not_includes html, "<embed"
  end

  test "links bare URLs with nofollow" do
    html = render_body("see https://example.com/show")
    assert_includes html, 'href="https://example.com/show"'
    assert_includes html, 'rel="nofollow ugc noopener"'
    assert_predicate html, :html_safe?
  end
end
