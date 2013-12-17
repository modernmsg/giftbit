require "kiind/version"

begin
	require 'rest-client'
rescue  LoadError
end

module Kiind
	@endpoint = "https://testbed.kiind.me/papi/v1/"
	@auth = "eyJ0eXAiOiJKV1QiLCJhbGciOiJTSEEyNTYifQ==.L2tzL3NnVHRKZUswZVhQSExTc0M4MzV6cUxmb2VucWR6emU2OVN5elVnQTU4cHEwY0Jvc0hCVFhidDhmb1o5dnE2dzFQV0JUNHhSUFRkTWU3cVdvY0E9PQ==.TpLYmrjpSsO1zPRgXOfukU2Mu16o+lVyIbmi9oZwHCY="
	
	class << self
    	attr_accessor :endpoint, :auth
  	end

	def self.getrequest(request)
		begin 
	 		client = RestClient::Resource.new "#{@endpoint}#{request}" , headers: {"Authorization" => "#{@auth}", "Accept" => "application/json"}
	 		# puts "***********#{client.url}***********"
	 		# puts "***********************************"
			res = client.get
			JSON.parse(res)
		rescue => e
			e
		end
 	end
	def self.account
		self.getrequest("") #endpoint itself returns the account info
	end
 	def self.marketplace(options = {})
 		# TODO support more options: like the url below
 		# https://www.kiind.me/papi/v1/marketplace?min_price_in_cents=1000&max_price_in_cents=5000&region=2&category=5&vendor=7&limit=20&offset=20
 		if options
 			request = "marketplace?"
 			if options[:vendor]
 				# check if vendor is a number
 				request += "vendor=#{options[:vendor]}"
 			elsif options[:limit]
 				request += "limit=#{options[:limit]}"
 			else
 				request = "marketplace"
 			end

 			self.getrequest("#{request}")
 		end
 	end
 	def self.regions
 		self.getrequest("marketplace/regions")
 	end
 	def self.vendors
 		self.getrequest("marketplace/vendors")
 	end
 	def self.categories
 		self.getrequest("marketplace/categories")
 	end

 	def self.campaign(options = {})
 		if options
 			request = "campaign"
 			if options[:id]
 				# todo: get campaign with id
 				request += "/#{options[:id]}"
 			end
 			self.getrequest("#{request}")
 		end
 	end

 	def self.getcampaign
 		
 	end

 	def self.postrequest(data)
 		begin
 			res = RestClient.post "#{endpoint}campaign", JSON.generate( data ),  headers: {"Authorization" => "#{@auth}", "Accept" => "application/json" ,  }
 			# client.post JSON.generate( data ),  { }
 			JSON.parse(res)
 		rescue => e
 			e
		end
 	end

 	def self.create_campaign_quote
 		# data = Hash[{ message: 'I am sorry that I shot you in the eye with a Nerf gun.Enjoy something from Ulla or Bliss on me', 
 		# 		 subject: 'Sorry', 
 		# 		 contacts: { firstname: "Graham", lastname: "Baradoy", email: "amvelasco@gmail.com" }, 
 		# 		 marketplace_gifts: { id: 1, price_in_cents: 5000}, 
 		# 		 expiry: "2015­12­20", 
 		# 		 id: "GiftToAdooylabs", 
 		# 		 quote: true }]

 		data = { message: "I am sorry that I shot you in the eye with a Nerf gun.Enjoy something from Ulla or Bliss on me", 
 				 subject: "test",
	 			 contacts: [{ firstname: "Audee", lastname: "Adooylabs", email: "auds@adooylabs.com"}],
 				 marketplace_gifts: [{ id: 1, price_in_cents: 5000}],
 				 expiry: "20151220",
 				 id: "GiftToAdooylabs",
 				 quote: true}

 		self.postrequest(data)
 		# data
 	end
end
