# Process raw Rack Response
module GrapeOAuth2
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

    def body
      @rack_response[2].body
    end
  end
end
