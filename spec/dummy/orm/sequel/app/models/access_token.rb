class AccessToken < ::Sequel::Model
  set_dataset :access_tokens
  include Grape::OAuth2::Sequel::AccessToken
end
