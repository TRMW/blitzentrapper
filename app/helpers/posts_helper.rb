module PostsHelper

def title_or_venue(post)
	if post.postable.attribute_present?('title')
		link_to post.postable.title, topic_path(post.postable, :anchor => post.id)
	else
		link_to post.postable.venue + ' - ' + post.postable.date.strftime('%m/%d/%y'), show_path(post.postable)
	end
end

end
