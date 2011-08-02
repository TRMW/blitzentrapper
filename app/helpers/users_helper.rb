module UsersHelper
  
  def user_tagline
  tagline = []
  	tagline << (@user.occupation? ? content_tag(:strong, @user.occupation) : 'Trapping')
  	tagline << 'in ' + content_tag(:strong, @user.location) if @user.location?
  	tagline << 'posting ' if @user.occupation?
  	tagline << 'since ' + content_tag(:strong, @user.created_at.strftime('%B %Y'))
  	tagline.join(' ')
  end
  
	def avatar(user, avatar_class)
		if user.fbid?
			if avatar_class == :default
				link_to image_tag('https://graph.facebook.com/' + user.fbid + '/picture?type=large', :class => 'avatar'), user_path(user)
			else
				link_to image_tag('https://graph.facebook.com/' + user.fbid + '/picture', :class => 'avatar'), user_path(user)
			end
		else
			link_to image_tag(user.avatar.url(avatar_class), :class => 'avatar'), user_path(user)
		end
	end
	
end
