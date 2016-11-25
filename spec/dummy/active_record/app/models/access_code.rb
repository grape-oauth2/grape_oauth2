class AccessCode < ApplicationRecord
  include Grape::OAuth2::ActiveRecord::AccessGrant
end
