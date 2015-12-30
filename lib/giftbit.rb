require 'giftbit/version'
require 'giftbit/base'

module Giftbit
  include Giftbit::Base

  module ClassMethods
    def account
      get ''
    end

    def marketplace(params = {})
      get 'marketplace', params: params
    end

    def regions(params = {})
      get 'marketplace/regions', params: params
    end

    def vendors(params = {})
      get 'marketplace/vendors', params: params
    end

    def categories(params = {})
      get 'marketplace/categories', params: params
    end

    def campaign(params = {})
      get 'campaign', params: params
    end

    def gifts(params = {})
      get 'gifts', params: params
    end

    def create_gift(body = {})
      body[:expiry] ||= (Date.today + 365).to_s
      body[:quote] = body[:quote] != false

      post 'campaign', body: body
    end

    def send_gift(id)
      put "campaign/#{id}"
    end

    def delete_gift(id)
      delete "campaign/#{id}"
    end

    def resend_gift(gift_uuid)
      put "gifts/#{gift_uuid}", body: {resend: true}
    end

    def get_links(campaign_id)
      get "links/#{campaign_id}"
    end
  end

  extend ClassMethods
end
