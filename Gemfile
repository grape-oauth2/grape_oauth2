source 'https://rubygems.org'

gemspec

platforms :jruby do
  gem 'jdbc-sqlite3'
end

platforms :ruby, :mswin, :mswin64, :mingw, :x64_mingw do
  gem 'sqlite3'
end

gem 'grape', '~> 0.16'
gem 'rack-oauth2', '~> 1.3'

group :test do
  gem 'rspec-rails', '~> 3.4'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
