require 'zip'

class ExportCsvController < ApplicationController
	def index
		posts = Micropost.where(user_id: current_user.id).where(created_at: (Time.now - 1.month)..Time.now)
		followeds = User.joins("INNER JOIN relationships ON users.id = relationships.followed_id AND relationships.follower_id = #{current_user.id}").select(:created_at, :name)
		followers = User.joins("INNER JOIN relationships ON users.id = relationships.follower_id AND relationships.followed_id = #{current_user.id}").select(:created_at, :name)
		attribute_follow = %w(name created_at).freeze
		

		export_posts = ExportCsvService.new posts, Micropost::CSV_ATTRIBUTES, 1
		export_followeds = ExportCsvService.new followeds, attribute_follow, 2
		export_followers = ExportCsvService.new followers, attribute_follow, 3

		filename = 'my_info.zip'
    	temp_file = Tempfile.new(filename)

    	begin 
    		Zip::OutputStream.open(temp_file) { |zos| }
			Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
           		zipfile.get_output_stream("your_post.csv") { |f| f.puts(export_posts.perform) }
           		zipfile.get_output_stream("your_followed.csv") { |f| f.puts(export_followeds.perform) }
           		zipfile.get_output_stream("your_follower.csv") { |f| f.puts(export_followers.perform) }
        	end
        	zip_data = File.read(temp_file.path)
        	send_data(zip_data, type: 'application/zip', filename: filename)
        ensure
			temp_file.close
        	temp_file.unlink
        end
	end
end
