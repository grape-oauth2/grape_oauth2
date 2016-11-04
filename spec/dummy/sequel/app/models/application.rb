class Application < ApplicationRecord
  set_dataset :applications
  include GrapeOAuth2::Sequel::Client
end
