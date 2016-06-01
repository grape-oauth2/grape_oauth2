ENV['RAILS_ENV'] ||= 'test'

require 'bundler/setup'
Bundler.setup

require 'airborne'
require 'database_cleaner'

require 'grape_oauth2'
require File.expand_path('../dummy/app/twitter', __FILE__)

RSpec.configure do |config|
  config.order = 'random'

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:deletion)
  end

  config.around(:example) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

Airborne.configure do |config|
  config.rack_app = Twitter::API
end
