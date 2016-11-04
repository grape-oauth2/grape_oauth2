class AccessToken < ApplicationRecord
  set_dataset :access_tokens
  include GrapeOAuth2::Sequel::AccessToken
end
