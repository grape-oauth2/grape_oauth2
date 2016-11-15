class AccessCode < ApplicationRecord
  set_dataset :access_codes
  include GrapeOAuth2::Sequel::AccessGrant
end
