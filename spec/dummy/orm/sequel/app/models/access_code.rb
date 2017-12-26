class AccessCode < ::Sequel::Model
  set_dataset :access_codes
  include Grape::OAuth2::Sequel::AccessGrant
end
