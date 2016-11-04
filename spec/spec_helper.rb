ENV['RAILS_ENV'] ||= 'test'
ENV['ORM'] ||= 'active_record'

puts "Configured ORM: '#{ENV['ORM']}'"

require 'bundler/setup'
Bundler.setup

require 'rack/test'
require 'database_cleaner'

ORM_GEMS_MAPPING = {
  'sequel' => 'sequel',
  'active_record' => 'active_record'
}.freeze

require ORM_GEMS_MAPPING[ENV['ORM']]

require 'grape_oauth2'
require File.expand_path("../dummy/#{ENV['ORM']}/app/twitter", __FILE__)

TWITTER_APP = Rack::Builder.parse_file(File.expand_path("../dummy/#{ENV['ORM']}/config.ru", __FILE__)).first

require 'support/api_helper'

RSpec.configure do |config|
  config.include ApiHelper

  config.filter_run_excluding skip_if: true

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
