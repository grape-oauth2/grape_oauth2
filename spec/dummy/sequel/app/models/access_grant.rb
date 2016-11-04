class AccessGrant < ApplicationRecord
  set_dataset :access_grants
  include GrapeOAuth2::Sequel::AccessGrant
end
