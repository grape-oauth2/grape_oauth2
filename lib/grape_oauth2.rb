require 'grape_oauth2/version'

# Mixins
if defined?(ActiveRecord)
  require 'grape_oauth2/mixins/active_record/access_token'
  require 'grape_oauth2/mixins/active_record/client'
end

# Authorization Grants
require 'grape_oauth2/strategies/password'

# Responses
require 'grape_oauth2/responses/token_response'

# Endpoints
require 'grape_oauth2/endpoint'

module GrapeOAuth2
  def self.config
    @config ||= GrapeOAuth2::Configuration.new
  end

  def self.configure
    yield config
  end
end
