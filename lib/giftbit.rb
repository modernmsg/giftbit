require 'giftbit/version'
require 'giftbit/base'

class Giftbit
  extend Base
  include Base

  # Class-level methods only work if you have a single API account. This lets
  # you instantiate the API for a given account, if you have multiple.
  def initialize(auth:)
    fail 'no auths set' unless auths = self.class.auths
    self.auth = auths.fetch(auth)
  end

  # This lets you call the same API requests on every account you have.
  # This is useful e.g. to check the status of every gift in every account.
  def self.each_auth
    fail 'no auths set' unless auths
    auths.each do |name, _|
      yield new auth: name
    end
  end

  def ==(other)
    other.is_a?(Giftbit) && auth == other.auth
  end

  module Methods
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

    def delete_campaign(id)
      delete "campaign/#{id}"
    end

    def delete_gift(gift_uuid)
      delete "gifts/#{gift_uuid}"
    end

    def resend_gift(gift_uuid)
      put "gifts/#{gift_uuid}", body: {resend: true}
    end

    def get_links(campaign_id)
      get "links/#{campaign_id}"
    end
  end

  extend Methods
  include Methods
end
