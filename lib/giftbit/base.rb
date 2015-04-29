begin
  require 'rest-client'
rescue LoadError
end

module Giftbit
  module Base
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      @endpoint = "https://api.giftbit.com/papi/v1/"
      @auth = ""

      attr_accessor :endpoint, :auth

      # Default resources options included in each request below
      def default_resource_options
        {
          headers: {
            "Authorization" => "#{@auth}",
            "Accept"        => "application/json"
          }
        }
      end

      # Convenience method for building a RestClient::Resource
      def resource(options = {})
        RestClient::Resource.new @endpoint, default_resource_options.merge(options)
      end

      # Convenience method for parsing and error handling a request
      def response(method, resource, options = {})
        body   = options.delete(:body)

        if body.nil? or options.empty?
          response = resource.send(method)
        elsif body
          resource.send(method, body, options)
        else
          resource.send(method, options)
        end

        JSON.parse response
      rescue RestClient::Unauthorized => e
        JSON.parse e.response
      end

      # GET (parsed) response from resources
      def get(path, request_options = {}, resource_options = {})
        response(:get, resource(resource_options)[path], request_options)
      end

      # DELETE (parsed) response from resources
      def delete(path, request_options = {}, resource_options = {})
        response(:delete, resource(resource_options)[path], request_options)
      end

      # POST (parsed) response from resources
      def post(path, request_options = {}, resource_options = {})
        request_options[:headers] ||= {}
        request_options[:headers][:content_type] ||= :json
        response(:post, resource(resource_options)[path], request_options)
      end

      # PUT (parsed) response from resources
      def put(path, request_options = {}, resource_options = {})
        request_options[:headers] ||= {}
        request_options[:headers][:content_type] ||= :json
        response(:post, resource(resource_options)[path], request_options)
      end
    end
  end
end