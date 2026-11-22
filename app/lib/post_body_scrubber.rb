# Cleans forum post HTML before it's shown, so a post can't run scripts or
# load content from arbitrary sites. Keeps the formatting the Trix editor
# makes (and Rails' standard safe tags), image attachments, video embeds
# from YouTube and Vimeo, and inline styles limited to Loofah's safe CSS
# properties (so strikethrough and colors stay, but not positioning or URLs).
class PostBodyScrubber < Rails::HTML::PermitScrubber
  TAGS = (Rails::HTML5::SafeListSanitizer.allowed_tags.to_a + %w[figure figcaption iframe]).freeze
  ATTRIBUTES = (Rails::HTML5::SafeListSanitizer.allowed_attributes.to_a + %w[allowfullscreen frameborder style]).freeze
  # Tags whose content is dropped along with the tag, instead of being kept as text.
  PRUNED_TAGS = %w[script style iframe object embed].freeze
  EMBED_SOURCE = %r{\Ahttps?://(www\.)?(youtube\.com/embed/|youtube-nocookie\.com/embed/|player\.vimeo\.com/video/)}i

  def initialize
    super
    self.tags = TAGS
    self.attributes = ATTRIBUTES
  end

  protected

  def allowed_node?(node)
    return node["src"].to_s.match?(EMBED_SOURCE) if node.name == "iframe"

    super
  end

  def scrub_node(node)
    if PRUNED_TAGS.include?(node.name)
      node.remove
    else
      super
    end
  end
end
