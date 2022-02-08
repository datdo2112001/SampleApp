module UsersHelper
	def gravatar_for(user, options = { size: 80 }) 
		if (user.image == nil)
			size = options[:size]
			gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
			gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
			image_tag(gravatar_url, alt: user.name, class: "gravatar")
		else 
			size = options[:size]
			image_tag(user.image, alt: user.name, class: "gravatar")
		end
    end

end
