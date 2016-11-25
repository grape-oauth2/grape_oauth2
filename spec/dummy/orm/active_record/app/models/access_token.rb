class AccessToken < ApplicationRecord
  include Grape::OAuth2::ActiveRecord::AccessToken
end
