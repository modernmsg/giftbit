require 'giftbit/version'
require 'giftbit/base'

module Giftbit
  include Giftbit::Base

  # Convenience methods to interact with resources on top of Giftbit::Base
  class << self
    # Root of resource returns account info
    def account
      get ''
    end

    # Marketplace resource
    def marketplace(params = {})
      get 'marketplace', params: params
    end

    # Regions resource
    def regions
      get 'marketplace/regions'
    end

    # Vendors resource
    def vendors
      get 'marketplace/vendors'
    end

    # Categories resource
    def categories
      get 'marketplace/categories'
    end

    # Campaign resource
    def campaign(params = {})
      get 'campaign', params: params
    end

    # Create a gift
    def creategift(params = {})
      params[:expiry] ||= (Date.today + 365).to_s
      params[:quote] = params[:quote] != false

      post 'campaign', body: params
    end

    # Send a gift
    def sendgift(id)
      put "campaign/#{id}"
    end

    # Delete a gift
    def deletegift(id)
      delete "campaign/#{id}"
    end
  end
end
