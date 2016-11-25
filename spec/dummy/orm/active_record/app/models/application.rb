class Application < ApplicationRecord
  include Grape::OAuth2::ActiveRecord::Client
end
