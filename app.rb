require 'bundler/setup'
Bundler.require(:default)

require 'pry'
require 'json'
require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'musicbrainz'
require 'wikipedia'

require_relative 'models/mbrainz'
require_relative 'models/countries'

before do
	MBrainz.init
end

get "/" do
	@main_page = true
  erb :index
end

post "/" do
	redirect "/search/#{URI.escape(params[:search])}"
end

get "/search/:search" do
  name   = params[:search].chomp
  @names = MBrainz.basic_name_search(name)
  redirect '/' if @names.nil?
  erb :index
end

get "/:name/:mbid" do
	@mbid = params[:mbid]
	@name = params[:name]
	@artist_information = MBrainz.artict_information(@mbid)

	
	query_with_artist = Wikipedia.find(@name + " (artist)")
	@page = query_with_artist.content.nil? ? Wikipedia.find(@name) : query_with_artist

	@artist_image = @page.image_urls.first
	
	if @page.sanitized_content.nil?
		@artist_description = ""
	else
		@artist_description = @page.sanitized_content.split("</p>")[0,2].join.sub("==","<strong>")
		@artist_description = @artist_description.sub("==",":</strong>")
	end

	@social_urls = @artist_information["social_urls"]
	@url = MBrainz.social_urls(@social_urls)

	erb :artist
end