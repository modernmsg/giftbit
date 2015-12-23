require 'giftbit/version'
require 'giftbit/base'

module Giftbit
  include Giftbit::Base

  # Convenience methods to interact with resources on top of Giftbit::Base
  module ClassMethods
    # Root of resource returns account info
    def account
      get ''
    end

    # Marketplace resource
    def marketplace(params = {})
      get 'marketplace', params: params
    end

    # Regions resource
    def regions(params = {})
      get 'marketplace/regions', params: params
    end

    # Vendors resource
    def vendors(params = {})
      get 'marketplace/vendors', params: params
    end

    # Categories resource
    def categories(params = {})
      get 'marketplace/categories', params: params
    end

    # Campaign resource
    def campaign(params = {})
      get 'campaign', params: params
    end

    def gifts(params = {})
      get 'gifts', params: params
    end

    # Create a gift
    def create_gift(body = {})
      body[:expiry] ||= (Date.today + 365).to_s
      body[:quote] = body[:quote] != false

      post 'campaign', body: body
    end


    # Send a gift
    def send_gift(id)
      put "campaign/#{id}"
    end

    # Delete a gift
    def delete_gift(id)
      delete "campaign/#{id}"
    end

    # Re-send a gift email
    def resend_gift(gift_uuid)
      put "gifts/#{gift_uuid}", body: { resend: true }
    end

    def get_links(campaign_id)
      get "links/#{campaign_id}"
    end
  end

  extend ClassMethods
end
