$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'grape_oauth2/version'

Gem::Specification.new do |gem|
  gem.name        = 'grape_oauth2'
  gem.version     = GrapeOAuth2.gem_version
  gem.authors     = ['Nikita Bulai']
  gem.date        = '2016-05-31'
  gem.email       = ['bulajnikita@gmail.com']
  gem.homepage    = 'http://github.com/nbulaj/grape-oauth2'
  gem.summary     = 'Grape OAuth2 provider'
  gem.description = 'Provides flexible, ORM-agnostic, fully customizable and simple OAuth2 support for Grape APIs'
  gem.license     = 'MIT'

  gem.require_paths = %w(lib)
  gem.files = `git ls-files`.split($RS)
  gem.test_files = Dir['spec/**/*']

  gem.required_ruby_version = '>= 2.2.2'

  gem.add_runtime_dependency 'grape', '>= 0.16'
  gem.add_runtime_dependency 'rack-oauth2', '>= 1.3.0'

  gem.add_development_dependency 'rspec-rails', '~> 3.4.0'
  gem.add_development_dependency 'database_cleaner', '~> 1.5.0'
end
