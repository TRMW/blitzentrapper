module UsersHelper

  def user_tagline
  tagline = []
    tagline << (@user.occupation? ? content_tag(:strong, @user.occupation) : 'Trapping')
    tagline << 'in ' + content_tag(:strong, @user.location) if @user.location?
    tagline << 'posting ' if @user.occupation?
    tagline << 'since ' + content_tag(:strong, @user.created_at.strftime('%B %Y'))
    tagline.join(' ')
  end

  def avatar_image(user, avatar_size = nil)
    if user.new_record?
      return image_tag('avatars/btdefault.gif', :class => 'avatar-image')
    end

    avatar_class = avatar_size == :tiny ? 'avatar-image avatar-image--tiny' : 'avatar-image'

    if user.fbid?
      if avatar_size == :tiny
        link_to image_tag("https://graph.facebook.com/#{user.fbid}/picture", :class => avatar_class), user_path(user)
      else
        link_to image_tag("https://graph.facebook.com/#{user.fbid}/picture?type=large", :class => avatar_class), user_path(user)
      end
    else
      if user.avatar.attached?
        resize_string = avatar_size == :tiny ? '30x30' : '115x115'
        begin
          image_path = user.avatar.variant(resize: resize_string)
        rescue ActiveStorage::InvariableError
          # Some old Paperclip attachments (BMPs, animated GIFs) seem to barf when
          # generating variants, so fall back to unresized
          image_path = user.avatar
        end
        link_to image_tag(image_path, :class => avatar_class), user_path(user)
      else
        link_to image_tag('avatars/btdefault.gif', :class => avatar_class), user_path(user)
      end
    end
  end

end
