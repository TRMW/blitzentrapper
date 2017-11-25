require 'csv'

class Post < ActiveRecord::Base
  belongs_to :user, autosave: true
  belongs_to :postable, :polymorphic => true, autosave: true
  validates_presence_of :body
  scope :visible, -> {
    where(:visible => true)
  }
  after_create :update_postable_freshness
  after_destroy :reset_postable_freshness

  def self.set_visibility
    for post in Post.all
      post.visible = true
      post.save
    end
  end

  def update_postable_freshness
    postable.last_post_date = created_at
    postable.save
  end

  # Set to nil if there are no longer any posts, otherwise update
  def reset_postable_freshness
    if postable.posts.empty?
      postable.last_post_date = "nil"
    else
      postable.last_post_date = postable.posts.last.created_at
    end
    postable.save
  end

  def self.get_html(slug, long_url)
    file_path = "app/assets/posts-cache/#{slug}.html"

    if file = File.exist?(file_path)
      logger.info "read locally cached file for #{slug}"
      file = File.open(file_path)
      return Nokogiri::HTML(file)
    else
      begin
        logger.info "fetching #{slug} from Google's cache"
        download = open("http://webcache.googleusercontent.com/search?q=cache:#{long_url}").read
        file = File.open(file_path, "w")
        file.write(download)
        file.close
        return Nokogiri::HTML(download)
      rescue OpenURI::HTTPError
        return false
      end
    end
  end

  def self.fetch_user_info(user_slug, post, is_forum_post)
    user_html = Post.get_html("users/#{user_slug}", "http://www.blitzentrapper.net/users/#{user_slug}")
    return false unless user_html

    user_image = user_html.css('.avatar').first
    set_avatar_fields_from_url(user_image['src'], post)
    user_meta = user_html.css('.usermeta').first
    matches = /(.*) in (.*) posting since/.match(user_meta.inner_text.squish)
    if matches
      if matches[1] != 'Trapping'
        post.user.occupation = matches[1].to_s
      end
      post.user.location = matches[2].to_s
    else matches = /(\s*)(.*) since/.match(user_meta.inner_text.squish)
      if matches[1] != 'Trapping'
        post.user.occupation = matches[1].to_s
      end
    end
    if /Ask me about /.match(user_meta.next_element.inner_text)
      post.user.interests = user_meta.next_element.css('strong').inner_text
    end
    if user_meta.previous_element.matches?('p')
      post.user.url = user_meta.previous_element.css('a').first['href']
    end
  end

  def self.set_avatar_fields_from_url(avatar_url, post)
    if matches = /graph\.facebook\.com\/(.*)\/picture/.match(avatar_url)
      post.user.fbid = matches[1]
    elsif matches = /\/avatars\/(?:.*)\/(.*\..*)$/.match(avatar_url)
      post.user.avatar_file_name = matches[1]
    end
  end

  def self.get_forum_post_dom(link_slug, long_url, post)
    logger.info "fetching forum post: #{link_slug}, #{long_url}"
    post_dom = false
    if post_html = get_html(link_slug, long_url)
      post_html.css('.postmeta a').each do |node|
        # Search for post ID form anchorlink
        if /.*##{post.id}$/.match(node['href'])
          post_dom = node
          # body may have already been fetch from RSS hash
          post.body ||= post_dom.ancestors('.postright').first.last_element_child.to_html
          break
        end
      end
    end
    return post_dom
  end

  def self.get_show_post_dom(link_slug, long_url, post, post_clip)
    logger.info "fetching showpost: #{link_slug}, #{long_url}"
    post_dom = false
    if html = get_html(link_slug, long_url)
      html.css('.post-body').each do |node|
        # No post ID, so search for postbody
        if node.inner_text.include? post_clip
          post_dom = node
          # body may have already been fetched from RSS hash
          post.body ||= post_dom.first_element_child.to_html
          break
        end
      end
    end
    return post_dom
  end

  def self.set_post_show(title, post)
    title_matches = /(.*) - (.*)/.match(title)
    show_venue = title_matches[1]
    if show_venue == 'Downtown Artery'
      show_venue = 'Down Town Artery'
    end
    show_date = Date.strptime(title_matches[2], "%m/%d/%y")
    post.postable = Show.find_by_venue_and_date(show_venue, show_date)
  end

  def self.restore_old_posts
    posts = []
    misses = []

    # build a hash of Feedburner posts to check against
    feed_posts_hash = {}
    feed_posts = File.open('app/assets/posts.xml') { |f| Nokogiri::XML(f) }
    feed_posts.css('entry').each do |node|
      node_body = node.css('content').inner_text.to_s.gsub(/<img src="http:\/\/feeds\.feedburner\.com\/(?:.*)" height="1" width="1" alt=""\/>/, '')
      node_text = /^(?:<div>|<p>)?([^<]*)/.match(node_body)[1]
      # for some reason this has to be 21 even though we clip to 20 below /shrug
      node_clip = node_text[0, 21]
      feed_posts_hash[node_clip] = node_body
    end

    # Loop through TrapperBoard tweet export
    CSV.foreach('app/assets/tweets.csv') do |row|
      post = Post.new(:created_at => row[3])

      tweet_text = row[5]
      matches = /^(.*?) on (.*)\: (.*) http/.match(tweet_text.squish)
      if matches
        author = matches[1]
        title = matches[2]
        post.user = User.find_or_initialize_by_name(author)
        post_tweet_excerpt = matches[3]
        post_clip = post_tweet_excerpt[0..20]
      end

      url = row[9]
      if /^http:\/\/bit\.ly/.match(url)
        results = JSON.parse(open("https://api-ssl.bitly.com/v3/expand?login=trmw&apiKey=R_e7ec8448751686ef3b0ba600dfe91851&shortUrl=#{url}").read())
        long_url = results['data']['expand'][0]['long_url'].gsub('?utm_source=twitterfeed&utm_medium=twitter', '')
      else
        long_url = url
      end

      if matches = /\/forum\/(.*)#(\d*)$/.match(long_url)
        is_forum_post = true
        link_slug = matches[1]
        if title == "Songbook Tour Disappointment - L.A."
          title = "Songbook Tour Critique: What Happend?"
        end
        post.postable = Topic.find_or_initialize_by_title(title)
        if post.postable.new_record?
          post.postable.created_at = post.created_at
          post.postable.slug = link_slug
        end
        post.id = matches[2]
      elsif matches = /\/shows\/(.*)$/.match(long_url)
        is_forum_post = false
        link_slug = matches[1]
        set_post_show(title, post)
        # Have to manually increment ID here to avoid conflict with manual IDs
        # for forum posts above
        post.id = Post.maximum(:id) + 1
      end

      if body = feed_posts_hash[post_clip]
        post.body = body
      end

      if is_forum_post
        post_dom = get_forum_post_dom(link_slug, long_url, post)
      else
        post_dom = get_show_post_dom(link_slug, long_url, post, post_clip)
      end

      if post_dom && post.user.new_record?
        post.user.created_at = post.created_at
        post.user.reset_persistence_token
        if is_forum_post
          user_link = post_dom.ancestors('.postright').first.previous_element.first_element_child
        else
          user_link = post_dom.parent.first_element_child
        end
        user_slug = user_link['href'].gsub('/users/', '')
        # Try to pull user info from Google cache
        unless fetch_user_info(user_slug, post, is_forum_post)
          # Pull what info we can from the post page if Google doesn't have the
          # user page cached
          user_image = user_link.css('img').first
          set_avatar_fields_from_url(user_image['src'], post)
        end
        post.user.slug = user_slug
        post.user.login = post.user.name
      end

      unless post.body
        post.body = "#{post_tweet_excerpt}<p><em>Editor's Note: We accidentally blew away a few forum posts recently, so all we have of this one is an excerpt. If it's yours, please feel free to edit it back to it's former glory (and delete the note). Sorry about this!</em></p>"
        misses << post.inspect
      end

      posts << post
      post.save(:validate => false)
    end

    csv_length = CSV.read('app/assets/tweets.csv').length
    logger.info "got #{posts.length} of #{csv_length} forum tweets!"
    logger.info "#{misses.length } misses: #{misses}"
  end
end
