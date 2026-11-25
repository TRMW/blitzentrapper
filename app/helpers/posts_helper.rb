module PostsHelper
def title_or_venue(post)
  if post.postable.attribute_present?("title")
    link_to post.postable.title, topic_path(post.postable, anchor: post.id)
  else
    link_to post.postable.venue + " - " + post.postable.date.strftime("%m/%d/%y"), show_path(post.postable)
  end
end

def title_or_venue_text(post)
  if post.postable.attribute_present?("title")
    post.postable.title
  else
    post.postable.venue + " - " + post.postable.date.strftime("%m/%d/%y")
  end
end

def title_or_venue_link(post)
  if post.postable.attribute_present?("title")
    topic_url(post.postable, anchor: post.id)
  else
    show_url(post.postable)
  end
end

# Old post uploads link to http://files.blitzentrapper.net. Serve them over
# HTTPS so browsers don't block or auto-upgrade them as mixed content.
LEGACY_FILES_HOST = %r{\bhttps?://files\.blitzentrapper\.net/}i
FILES_HOST = "https://files.blitzentrapper.net/".freeze

# A post's body as safe HTML: scrubbed of scripts and unsafe markup, with
# bare URLs turned into links.
def post_body(post)
  auto_link(
    post.body.to_s.gsub(LEGACY_FILES_HOST, FILES_HOST),
    html: { target: "_blank", rel: "nofollow ugc noopener" },
    sanitize_options: { scrubber: PostBodyScrubber.new }
  )
end

def nice_date(date)
  if date > Time.now - 14.days
    time_ago_in_words(date) + " ago"
  else
    date.strftime("%-m/%-d/%y")
  end
end
end
