# MBrainz Class
require_relative 'countries'

class MBrainz

	def self.init
		MusicBrainz.configure do |c|
	  	# Application identity (required)
	  	c.app_name = "My Music App"
	  	c.app_version = "1.0"
	  	c.contact = "support@mymusicapp.com"

	  	# Cache config (optional)
	  	c.cache_path = "/tmp/musicbrainz-cache"
	  	c.perform_caching = true

	  	# Querying config (optional)
	  	c.query_interval = 1.2 # seconds
	  	c.tries_limit = 2
		end
	end
	
	# Search for artists
	def self.search(name)
		result = MusicBrainz::Artist.search(name)
		return result != nil ? result : {}
	end

	# Find artist by name
	def self.find_by_name(name)
		result = MusicBrainz::Artist.find_by_name(name)
		return result != nil ? result : {}
	end

	# Get MBID by name
	def self.get_mbid(name)
		result = self.find_by_name(name).id
		return result != nil ? result : ""
	end

	def self.date(date, sym="/")
		array = date.to_s.split("-")
		return "unknown" if date == nil || date =="" || array[0] == nil || array[1] == nil || array[2] == nil
		return array[2] + sym + array[1] + sym + array[0]
	end

	# returning a hash with all name's information from the basic search
	def self.basic_name_search(name)
		search = self.search(name)  # basic name's search
  
	  ids    = search.map { |x| x[:id]    }  # Array of ids from basic search 
	  mbids  = search.map { |x| x[:mbid]  }  # Array of mbids from basic search 
	  names  = search.map { |x| x[:name]  }  # Array of names from basic search
	  scores = search.map { |x| x[:score] }  # Array of scores from basic search

	  results = {}
	  mbids.each_with_index do |mbid, index| # looping the mbid's array for specific information
		  result = self.find_by_mbid(mbid)     # Searching per mbid
		  results[mbids[index].to_sym] = [scores[index], names[index], result.type, Country.full_name(result.country), self.date(result.date_begin), self.date(result.date_end)]
		end

		return results
	end

	# Find artist by mbid
	def self.find_by_mbid(mbid)
		result = MusicBrainz::Artist.find(mbid)
		return result != nil ? result : {}
	end

	def self.albums(mbid, category)
		result = self.find_by_mbid(mbid).release_groups.map { |release|
			category.include?("date_") || category.include?("_date") ? self.date(release.send(category)) : release.send(category)
		}
		return result != nil ? result : {}
	end

	def self.artict_information(mbid)
		result = {}
		result["ids"]      = self.albums(mbid, "id")
		result["titles"]   = self.albums(mbid, "title")
		result["releases"] = self.albums(mbid, "first_release_date")
		result["types"]    = self.albums(mbid, "type")
		result["urls"]     = self.albums(mbid, "urls")
		result["social_urls"] = self.find_by_mbid(mbid).urls[:social_network]
		result["social_urls"] = [] if result["social_urls"] == nil
		result["information"] = self.find_by_mbid(mbid)

		return result
	end

	def self.social_urls(social_urls_array)
		%w(twitter facebook instagram youtube last.fm imdb discography).inject({}){ |h, v| h[v] = social_urls_array.find {|b| b=~/#{v}/}; h}
	end

	def self.get_image_by_name(str, size="large")
		web_service_url = "http://coverartarchive.org"
		url = web_service_url + "/release/" + self.get_mbid(str)
		response = HTTParty.get(url)
		json_image = JSON(response)

		json_image["images"][0]["thumbnails"]["#{size}"]
	end
end