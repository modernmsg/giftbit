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
			res = client.get
			JSON.parse(res)
		rescue => e
			JSON.parse(e.response)
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

 	def self.postrequest(data)
 		begin
 			client = RestClient::Resource.new "#{endpoint}campaign", headers: {"Authorization" => "#{@auth}", "Accept" => "application/json" , :content_type => :json }
 			res = client.post(data)
 			JSON.parse(res)
 		rescue => e
 			JSON.parse(e.response)
		end
 	end

 	def self.creategift(options = {})
 		#*** this is a working json
 		#
		# data = '{
		# 		  "message":"this is from modenrmsg",
		# 		  "subject":"gift card from modernmsg",
		# 		  "contacts": [{"firstname":"Audee", "lastname":"Velasco","email":"auds@adooylabs.com"}],
		# 		  "marketplace_gifts": [{"id":1,"price_in_cents":5000}],
		# 		  "id":"GiftCardTo808",
		# 		  "expiry":"2012-12-20",
		# 		  "quote":true
		# 		}'

		# Kiind.creategift(message: "Thank you for being an awesome person", subject: "Present from ModemMsg", contacts: [{firstname: "Audee", lastname: "Velasco", email: "auds@adooylabs.com"}], marketplace_gifts: [{id:1, price_in_cents:5000}], id: "UserGenID001")

		#if expiry not set, set it to one year
		unless options["expiry"]
			options["expiry"] = (Date.today + 365).to_s
		end

		#if quote not set, set it to TRUE
		unless options["quote"]
			options["quote"] = true
		end
		
 		self.postrequest(options.to_json)
 	end

 	def self.sendgift(id)
 		begin
	 		client = RestClient::Resource.new "#{endpoint}campaign/#{id}", headers: {"Authorization" => "#{@auth}", "Accept" => "application/json"}
	 		res = client.put headers: {"Accept" => "application/json"}
	 		JSON.parse(res)
	 	rescue => e
	 		JSON.parse(e.response)
	 	end
 	end

 	def self.deletegift(id)
 		begin
	 		client = RestClient::Resource.new "#{endpoint}campaign/#{id}", headers: {"Authorization" => "#{@auth}", "Accept" => "application/json"}
	 		res = client.delete
	 		JSON.parse(res)
	 	rescue => e
	 		JSON.parse(e.response)
	 	end
 	end
end
