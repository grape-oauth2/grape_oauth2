# Process raw Rack Response
module Grape
  module OAuth2
    module Responses
      class Base
        attr_reader :rack_response

        def initialize(rack_response)
          # Rack Body:
          #   [Status Code, Headers, Body]
          @rack_response = rack_response
        end

        def status
          @rack_response[0]
        end

        def headers
          @rack_response[1]
        end

        def raw_body
          @rack_response[2].body
        end

        def body
          @_body ||= begin
            response_body = raw_body.first
            return {} if response_body.nil? || response_body.empty?

            JSON.parse(response_body)
          end
        end
      end
    end
  end
end
