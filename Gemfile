source 'https://rubygems.org'

gemspec

gem 'grape', '~> 1.4'
gem 'rack-oauth2'

gem 'activerecord'
gem 'bcrypt'

group :test do
  platforms :ruby, :mswin, :mswin64, :mingw, :x64_mingw do
    gem 'sqlite3'
  end

  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'otr-activerecord'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec-rails', '~> 3.5'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
