module Grape
  module OAuth2
    # Grape::OAuth2 responses namespace.
    module Responses
      # Base class for Grape::OAuth2 endpoints responses.
      # Processes raw Rack Responses and contains helper methods.
      class Base
        # Raw Rack::Response to process
        #
        # @return [Array] Rack response
        #
        # @example
        #   response = Grape::OAuth2::Responses::Base.new([200, {}, Rack::BodyProxy.new('Test')])
        #   response.rack_response
        #
        #   #=> [200, {}, Rack::BodyProxy.new('Test')]
        #
        attr_reader :rack_response

        # OAuth2 response class.
        #
        # @param rack_response [Array]
        #   raw Rack::Response object
        #
        def initialize(rack_response)
          # Rack Body:
          #   [Status Code, Headers, Body]
          @rack_response = rack_response
        end

        # Response status
        def status
          @rack_response[0]
        end

        # Response headers
        def headers
          @rack_response[1]
        end

        # Raw Rack body
        def raw_body
          @rack_response[2].body
        end

        # JSON-parsed body
        def body
          response_body = raw_body.first
          return {} if response_body.nil? || response_body.empty?

          JSON.parse(response_body)
        end
      end
    end
  end
end
