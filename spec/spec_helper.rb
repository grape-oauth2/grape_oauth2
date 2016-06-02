ENV['RAILS_ENV'] ||= 'test'

require 'bundler/setup'
Bundler.setup

require 'rack/test'
require 'database_cleaner'

require 'grape_oauth2'
require File.expand_path('../dummy/app/twitter', __FILE__)

TWITTER_APP = Rack::Builder.parse_file(File.expand_path('../dummy/config.ru', __FILE__)).first

require 'support/api_helper'

RSpec.configure do |config|
  config.include ApiHelper

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
