source 'https://rubygems.org'

gemspec path: '../'

platforms :jruby do
  gem 'jdbc-sqlite3'
end

platforms :ruby, :mswin, :mswin64, :mingw, :x64_mingw do
  gem 'sqlite3'
end

gem 'otr-activerecord'

gem 'activerecord'
gem 'bcrypt'

group :test do
  gem 'rspec-rails', '~> 3.5'
  gem 'database_cleaner'
  gem 'rack-test', require: 'rack/test'
  gem 'coveralls', require: false
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
