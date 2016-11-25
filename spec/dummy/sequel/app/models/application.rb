class Application < ApplicationRecord
  set_dataset :applications
  include Grape::OAuth2::Sequel::Client
end
