class Application < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::Client
end
