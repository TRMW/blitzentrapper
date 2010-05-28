module UsersHelper
  def avatar_image_tag(login, name)
	  if File.exists?('public/images/avatars/' + login + '.jpg')
	  	image_tag 'avatars/' + login + '.jpg', :class => "avatar", :title => name
	  elsif File.exists?('public/images/avatars/' + login + '.gif')
	  	image_tag 'avatars/' + login + '.gif', :class => "avatar", :title => name
	  elsif File.exists?('public/images/avatars/' + login + '.png')
	  	image_tag 'avatars/' + login + '.png', :class => "avatar", :title => name
	  else image_tag 'avatars/btdefault.gif', :class => "avatar", :title => name
	  end
  end
  
  def user_tagline
  tagline = []
  	tagline << (@user.occupation? ? content_tag(:strong, @user.occupation) : 'Trapping')
  	tagline << 'in ' + content_tag(:strong, @user.location) if @user.location?
  	tagline << 'posting ' if @user.occupation
  	tagline << 'since ' + content_tag(:strong, @user.created_at.strftime('%B %Y'))
  	tagline.join(' ')
  end
end
