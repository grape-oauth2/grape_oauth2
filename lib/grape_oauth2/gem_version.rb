module Grape
  module OAuth2
    # Grape::OAuth2 version.
    # @return [Gem::Version] version of the gem
    #
    def self.gem_version
      Gem::Version.new VERSION::STRING
    end

    # Grape::OAuth2 semantic versioning module.
    # Contains detailed info about gem version.
    module VERSION
      # Major version of the gem
      MAJOR = 0
      # Minor version of the gem
      MINOR = 2
      # Tiny version of the gem
      TINY  = 0

      # Full gem version string
      STRING = [MAJOR, MINOR, TINY].compact.join('.')
    end
  end
end
