module Twitter
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    helpers GrapeOAuth2::Helpers::AccessTokenHelpers

    mount GrapeOAuth2::Endpoint
  end
end
