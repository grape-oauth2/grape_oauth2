source 'https://rubygems.org'

gemspec path: '../'


gem 'grape', '~> 0.16'
gem 'rack-oauth2'
gem 'mongoid', '~> 6'

group :test do
  gem 'rspec-rails', '~> 3.4'
  gem 'database_cleaner'
  gem 'rack-test', require: 'rack/test'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
