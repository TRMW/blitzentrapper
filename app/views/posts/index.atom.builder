atom_feed do |feed|
	feed.title("Blitzen Trapper Posts")
	feed.updated(@posts.last.updated_at)
	
	@posts.each do |post|
		feed.entry(post) do |entry|
			entry.title(post.user.name + ' on ' + title_or_venue(post), :type => 'html')
			entry.content(post.body, :type => 'html')
			entry.published(post.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
			if post.updated_at
				entry.updated(post.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
			else
				entry.updated(post.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
			end
			entry.author { |author| author.name(post.user.name) }
		end
	end
end