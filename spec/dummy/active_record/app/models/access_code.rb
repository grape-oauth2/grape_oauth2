class AccessCode < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::AccessGrant
end
