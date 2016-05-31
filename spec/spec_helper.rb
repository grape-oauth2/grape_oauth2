require 'bundler/setup'
Bundler.setup

require 'grape_oauth2'

RSpec.configure do |config|
  config.order = 'random'
end
