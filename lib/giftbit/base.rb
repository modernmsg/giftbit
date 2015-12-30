require 'active_support'
require 'rest-client'

module Giftbit
  module Base
    def self.included(klass)
      klass.extend ClassMethods

      klass.endpoint ||= 'https://testbedapp.giftbit.com/papi/v1/'
      klass.auth     ||= ''
    end

    module ClassMethods
      attr_accessor :endpoint, :auth

      def default_resource_options
        {
          headers: {
            "Authorization" => "Bearer #{@auth}",
            "Accept"        => "application/json",
            "Content-Type"  => "json"
          }
        }
      end

      def resource(options = {})
        RestClient::Resource.new @endpoint, default_resource_options.deep_merge(options)
      end

      def response(method, resource, options = {})
        if body = options.delete(:body)
          JSON.parse resource.send(method, JSON.generate(body), options)
        else
          JSON.parse resource.send(method, options)
        end
      rescue => e
        if e.respond_to?(:response)
          JSON.parse(e.response)
        else
          raise
        end
      end

      def get(path, request_options = {}, resource_options = {})
        response :get, resource(resource_options)[path], request_options
      end

      def delete(path, request_options = {}, resource_options = {})
        response :delete, resource(resource_options)[path], request_options
      end

      def post(path, request_options = {}, resource_options = {})
        response :post, resource(resource_options)[path], request_options
      end

      def put(path, request_options = {}, resource_options = {})
        response :put, resource(resource_options)[path], request_options
      end
    end
  end
end