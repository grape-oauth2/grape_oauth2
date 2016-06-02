::ActiveRecord::Base.default_timezone = :utc

::ActiveRecord::Migration.verbose = false
::ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

load File.expand_path('../../../db/schema.rb', __FILE__)

::ActiveRecord::Base.logger = Logger.new(STDOUT) unless ENV['RAILS_ENV'] == 'test'
