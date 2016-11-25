class AccessCode < ApplicationRecord
  set_dataset :access_codes
  include Grape::OAuth2::Sequel::AccessGrant
end
