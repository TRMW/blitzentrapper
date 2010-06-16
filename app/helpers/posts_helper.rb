module PostsHelper

def title_or_venue(post)
	if post.postable.attribute_present?('title')
		link_to post.postable.title, topic_path(post.postable, :anchor => post.id)
	else
		link_to post.postable.venue + ' - ' + post.postable.date.strftime('%m/%d/%y'), show_path(post.postable)
	end
end

def title_or_venue_text(post)
	if post.postable.attribute_present?('title')
		post.postable.title
	else
		post.postable.venue + ' - ' + post.postable.date.strftime('%m/%d/%y')
	end
end

def title_or_venue_link(post)
	if post.postable.attribute_present?('title')
		topic_url(post.postable, :anchor => post.id)
	else
		show_url(post.postable)
	end
end

end
