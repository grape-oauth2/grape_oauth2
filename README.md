# Grape OAuth2
[![Build Status](https://travis-ci.org/nbulaj/grape-oauth2.svg?branch=master)](https://travis-ci.org/nbulaj/grape-oauth2)
[![Dependency Status](https://gemnasium.com/nbulaj/grape-oauth2.svg)](https://gemnasium.com/nbulaj/grape-oauth2)
[![Code Climate](https://codeclimate.com/github/nbulaj/grape-oauth2/badges/gpa.svg)](https://codeclimate.com/github/nbulaj/grape-oauth2)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

This gem adds a flexible OAuth2 server authentication to your [Grape](https://github.com/ruby-grape/grape) API project.

**Currently under development**.

## Installation

If you are using bundler, first add 'grape_oauth2' to your Gemfile:

```ruby
gem 'grape_oauth2'
```

And run:

```sh
bundle install
```

Otherwise simply install the gem:

```sh
gem install grape_oauth2
```

## Configuration

Main Grape OAuth2 configuration must be placed in `config/initializers/` (in case you are using [Rails](https://github.com/rails/rails)) or in some place, that will be processed at the application startup:

```ruby
GrapeOAuth2.configure do |config|
  # Access Tokens lifetime
  config.token_lifetime = 7200 # in seconds (2.hours for Rails)

  # Allowed OAuth2 Authorization Grants
  # config.allowed_grant_types = %w(password)

  # Issue access tokens with refresh token
  # config.refresh_token = true

  # Classes for OAuth2 Roles
  config.client_class = Application
  config.access_token_class = AccessToken
  config.resource_owner_class = User
end
```

As you know, OAuth2 workflow implies the existence of the next three roles: **AccessToken**, **Client** and **ResourceOwner**. So your project must include 3 classes (models) - _AccessToken_, _Application_ and _User_ for example. The gem needs to know what classes it work, so you need to create them and configure `GrapeOAuth2`.

`resource_owner_class` must have a `self.oauth_authenticate(client, username, password)` method, that returns an instance of the class if authentication successful (`username` and `password` matches for example) and `false` or `nil` in other cases.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  def self.oauth_authenticate(_client, username, password)
    # find the user by it username
    user = find_by(username: username)
    return if user.nil?

    # check the password
    user.authenticate(password)
  end
end
```

`client_class`, `access_token_class` and `resource_owner_class` classes must contain a specific set of API (methods), that are called by the gem. Grape OAuth2 includes predefined mixins for the projects that use the `ActiveRecord` or `Sequel` ORMs, and you can just include them into your models. 

### ActiveRecord

```ruby
# app/models/access_token.rb
class AccessToken < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::AccessToken
end

# app/models/application.rb
class Application < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::Client
end
```

Migration for the simplest use case of the gem looks as follows:

```ruby
ActiveRecord::Schema.define(version: 3) do
  create_table :users do |t|
    t.string :name
    t.string :username
    t.string :password_digest
  end

  create_table :applications do |t|
    t.string :name
    t.string :key
    t.string :secret

    t.timestamps null: false
  end

  add_index :applications, :key, unique: true

  create_table :access_tokens do |t|
    t.integer :resource_owner_id
    t.integer :client_id

    t.string :token, null: false
    t.string :refresh_token
    t.string :scopes

    t.datetime :expires_at
    t.datetime :revoked_at
    t.datetime :created_at, null: false
  end

  add_index :access_tokens, :token, unique: true
  add_index :access_tokens, :resource_owner_id
  add_index :access_tokens, :client_id
  add_index :access_tokens, :refresh_token, unique: true
end
```

### Sequel

```ruby
# app/models/access_token.rb
class AccessToken < Sequel::Model
  include GrapeOAuth2::Sequel::AccessToken
end

# app/models/application.rb
class Application < Sequel::Model
  include GrapeOAuth2::Sequel::Client
end
```

### Other ORMs

If your project doesn't use `ActiveRecord` or `Sequel`, then you must write your own classes with the next API (names of the classes can be customized, it's only an example):

#### Client

For the class that represents an OAuth2 Client you must define `has_many` relation with `AccessTokens` and authentication method (`self.authenticate(key, secret)`). Dont forget to setup class name in the Grape OAuth2 config.

#### AccessToken

For the class that represents an OAuth2 Access Token you must define `belongs_to` relations with `Client` and `ResourceOwner` classes and the next methods:

* `self.create_for(client, resource_owner)` - returns an instance of the class;
* `self.authenticate(token)` - returns an instance of the class if authenticated and `false`/`nil` in other cases;
* `expired?` - returns `true` if record is expired;
* `expires_in_seconds` - returns `nil` if token never expires and count of seconds in other case;
* `revoked?` - returns `true` if record is revoked;
* `revoke!(clock = Time)` - revoke the token;
* `accessible?` - returns `true` if record is not expired and is not revoked;
* `to_bearer_token` - returns an instance of `Rack::OAuth2::AccessToken::Bearer`.

You can take a look at the [Grape OAuth2 mixins](https://github.com/nbulaj/grape-oauth2/tree/master/lib/grape_oauth2/mixins) to understand what they are doing and what they are returning.

#### ResourceOwner

As was said before, Resource Owner class (`User` model for example) must contain only one class method (in case of Password Authorization Grant): `self.authenticate(client, username, password)`.

## Usage examples
### I'm lazy, give me all out of the box!

OK, if you need a simple common OAuth2 authentication process then you can use gem default OAuth2 endpoint. First you will need to configure GrapeOAuth2 as described above (create migrations, models and authentication methods). 

```ruby
# app/models/access_token.rb
class AccessToken < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::AccessToken
end

# app/models/application.rb
class Application < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::Client
end

# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  def self.oauth_authenticate(_client, username, password)
    user = find_by(username: username)
    return if user.nil?

    user.authenticate(password)
  end
end

# config/oauth2.rb
GrapeOAuth2.configure do |config|
  # Classes for OAuth2 Roles
  config.client_class = Application
  config.access_token_class = AccessToken
  config.resource_owner_class = User
end
```

After that just mount GrapeOAuth2 Token endpoint to your main API module:

```ruby
# app/twitter.rb
module Twitter
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    helpers GrapeOAuth2::Helpers::AccessTokenHelpers

    # What to do if somebody will request an API with access_token
    # Authenticate token and raise an error in case of authentication error
    use Rack::OAuth2::Server::Resource::Bearer, 'OAuth API' do |request|
      AccessToken.authenticate(request.access_token) || request.invalid_token!
    end

    # Moune default Grape OAuth2 Token endpoint
    mount GrapeOAuth2::Endpoints::Token
   
    # ...
  end
end
```

That's all!

### Hey, I wanna control all the authentication process!

If you need to do some special things (check if `client_id` starts with _'MyAPI'_ word for example), then you can just override default authentication methods in models like this (only if you are using gem mixins, in other case you **MUST** write it yourself):

```ruby
# app/models/application.rb
class Application < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::Client
  
  class << self
    def self.authenticate(key, secret)
      # My custom condition to successfful authentication
      return nil unless key.start_with?('MyAPI')

      find_by(key: key, secret: secret)
    end
  end
end
```

Besides, you can customize all the OAuth2 Token flow with your own API endpoint and do some stuffs with the help of the Grape OAuth2 gem.
Just create a common Grape API class, set optional OAuth2 params and process the request with the `GrapeOAuth2::TokenGenerator` class:

```ruby
# api/oauth2.rb
module MyAPI
  class OAuth2 < Grape::API
    resources :oauth do
      params do
        optional :grant_type, type: String, desc: 'The grant type'
        optional :code, type: String, desc: 'The authorization code'
        optional :client_id, type: String, desc: 'The client id'
        optional :client_secret, type: String, desc: 'The client secret'
        optional :refresh_token, type: String, desc: 'The refresh_token'
      end

      post :token do
        token_response = GrapeOAuth2::TokenGenerator.generate_for(env) do |request, response|
          # Customly authenticate client
          application = Application.find_by(key: request.client_id, active: true)
          request.invalid_client! unless application

          # Customly authenticate resource owner (User model)
          resource_owner = User.find_by(username: request.username)
          request.invalid_grant! if resource_owner.nil? || resource_owner.inactive?

          # Create an AccessToken for the client and resource_owner
          token = AccessToken.create_for(application, resource_owner)
          response.access_token = token.to_bearer_token
        end

        # If request is successful, then return it
        status token_response.status

        token_response.headers.each do |key, value|
          header key, value
        end

        body token_response.access_token
      end
    end
  end
end
```

## Example App

Take a look at the [sample application](https://github.com/nbulaj/grape-oauth2/tree/master/spec/dummy) in the "spec/dummy" project directory.

## Contributing

You are very welcome to help improve grape_oauth2 if you have suggestions for features that other people can use.

To contribute:t represents an OAuth2 Clien

1. Fork the project.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Run <tt>rake doc:yard</tt>. If your changes are not 100% documented, go back to step 4.
6. Add tests for your feature or bug fix.
7. Run `rake` to make sure all tests pass.
8. Commit your changes (`git commit -am 'Add new feature'`).
9. Push to the branch (`git push origin my-new-feature`).
10. Create new pull request.

Thanks.

## License

Grape OAuth2 gem is released under the [MIT License](http://www.opensource.org/licenses/MIT).

Copyright (c) 2014-2016 Nikita Bulaj (bulajnikita@gmail.com).
