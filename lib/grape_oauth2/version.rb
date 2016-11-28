require_relative 'gem_version'

module Grape
  module OAuth2
    # Grape::OAuth2 gem version.
    #
    # @return [Gem::Version]
    #   version value
    #
    def self.version
      gem_version
    end
  end
end
