OTR::ActiveRecord.configure_from_hash!(adapter: 'sqlite3', database: ':memory:')

::ActiveRecord::Base.default_timezone = :utc
::ActiveRecord::Base.logger = ENV['RAILS_ENV'] == 'test' ? nil : Logger.new(STDOUT)

::ActiveRecord::Migration.verbose = false
load File.expand_path('../../../db/schema.rb', __FILE__)
