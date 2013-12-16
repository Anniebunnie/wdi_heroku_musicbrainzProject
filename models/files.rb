# Files Class

class Files
	
	# append a new user to a texts file
	def self.create(username, locale, img_url)
		file = File.new(self.file_path, "a")
		file.puts("#{username}, #{locale}, #{img_url}")
		file.close
	end

	# retrieve an array of all usernames
	def self.all
		files = []
		file  = File.new(self.file_path, "r")
		file.each { |line| files << line.chomp.split(", ") }
		file.close
		return files
	end

	def self.file_path
		"./db/database.txt"
	end

	def self.find(username)
		#return user if it exists.
	end

	def self.delete(username)
		#delete a user based on username
	end

	def self.update(username, locale)
		#find user and update age
	end
end