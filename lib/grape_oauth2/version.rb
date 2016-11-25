require_relative 'gem_version'

module Grape
  module OAuth2
    def self.version
      gem_version
    end
  end
end
