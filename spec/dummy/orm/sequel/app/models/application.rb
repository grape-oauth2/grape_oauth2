class Application < ::Sequel::Model
  set_dataset :applications
  include Grape::OAuth2::Sequel::Client
end
