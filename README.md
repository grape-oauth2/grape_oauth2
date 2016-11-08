# Grape OAuth2
[![Build Status](https://travis-ci.org/nbulaj/grape_oauth2.svg?branch=master)](https://travis-ci.org/nbulaj/grape_oauth2)
[![Dependency Status](https://gemnasium.com/nbulaj/grape_oauth2.svg)](https://gemnasium.com/nbulaj/grape_oauth2)
[![Code Climate](https://codeclimate.com/github/nbulaj/grape_oauth2/badges/gpa.svg)](https://codeclimate.com/github/nbulaj/grape_oauth2)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

This gem adds a flexible OAuth2 ([RFC 6749](http://www.rfc-editor.org/rfc/rfc6749.txt)) server authentication to your [Grape](https://github.com/ruby-grape/grape) API project.

**Currently under development**.

Implemented features (flows):

- Resource Owner Password Credentials
- Client Credentials
- Refresh token
- Token revocation

Supported token types:

* Bearer

_In progress_:

- Access Token Scopes
- Access Grants
- Authorization endpoint
- Implicit Grant

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
  - [ActiveRecord](#activerecord)
  - [Sequel](#sequel)
  - [Other ORMs](#other-orms)
    - [Client](#client)
    - [AccessToken](#accesstoken)
    - [ResourceOwner](#resourceowner)  
- [Usage examples](#usage-examples)
  - [I'm lazy, give me all out of the box!](#im-lazy-give-me-all-out-of-the-box)
  - [Hey, I wanna control all the authentication process!](#hey-i-wanna-control-all-the-authentication-process)
- [Example App](#example-app)
- [Contributing](#contributing)
- [License](#license)

## Installation

If you are using bundler, first add 'grape_oauth2' to your Gemfile:

```ruby
gem 'grape_oauth2', git: 'https://github.com/nbulaj/grape_oauth2.git'
```

And run:

```sh
bundle install
```

## Configuration

Main Grape OAuth2 configuration must be placed in `config/initializers/` (in case you are using [Rails](https://github.com/rails/rails)) or in some place, that will be processed at the application startup:

```ruby
GrapeOAuth2.configure do |config|
  # Access Tokens lifetime
  config.token_lifetime = 7200 # in seconds (2.hours for Rails)

  # Allowed OAuth2 Authorization Grants
  # config.allowed_grant_types = %w(password client_credentials refresh_token)

  # Issue access tokens with refresh token
  # config.issue_refresh_token = true
  
  # Revoke token after using of refresh token
  # config.revoke_after_refresh = true

  # Classes for OAuth2 Roles
  config.client_class = Application
  config.access_token_class = AccessToken
  config.resource_owner_class = User
end
```

Currently implemented (partly on completely) grant types: _password, client_credentials, refresh_token_.

As you know, OAuth2 workflow implies the existence of the next three roles: **Access Token**, **Client** and **Resource Owner**. So your project must include 3 classes (models) - _AccessToken_, _Application_ and _User_ for example. The gem needs to know what classes it work, so you need to create them and configure `GrapeOAuth2`.

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
  # All the columns are custom
  create_table :users do |t|
    t.string :name
    t.string :username
    t.string :password_digest
  end

  # Required columns: :key & :secret
  create_table :applications do |t|
    t.string :name
    t.string :key
    t.string :secret

    t.timestamps null: false
  end

  add_index :applications, :key, unique: true

  # Required columns: :client_id, :resource_owner_id, :token, :expires_at, :revoked_at, :refresh_token
  create_table :access_tokens do |t|
    t.integer :resource_owner_id
    t.integer :client_id

    t.string :token, null: false
    t.string :refresh_token
    t.string :scopes, default: ''

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

If you want to use Grape OAuth2 endpoints, but your project doesn't use `ActiveRecord` or `Sequel`, then you must create at least 3 models (classes) to cover OAuth2 roles. Otherwise you can skip this step and do everything just as you want to.

If you decide to use your own classes with the default gem functionality, then you need to define a specific set ot API.

#### Client

Class that represents an OAuth2 Client should look as follows:

```ruby
class Client
  def self.authenticate(key, secret = nil)
    # Should return a Client instance matching the 
    # key & secret (if specified) provided.
  end
end
```

#### AccessToken

For the class that represents an OAuth2 Access Token you must define the next API:

```ruby
class AccessToken
  def self.create_for(client, resource_owner)
    # Creates the record in the database for the provided client and
    # resource owner. Returns an instance of that record.
  end

  def self.authenticate(token, token_type = :access_token)
    # Returns an Access Token instance matching the token provided.
    # Note that you MAY include expired access tokens in the result
    # of this method so long as you implement an instance #expired?
    # method.
    
    # Access Token can be searched by refresh_token value. In that case
    # token_type must be set to :refresh_token.
  end
  
  def expired?
    # true if the Access Token has reached its expiration.
  end

  def revoked?
    # true if the Access Token was revoked
  end

  def revoke!(revoked_at = Time.now)
    # Updates the instance of the Access Token in the database
    # by setting its :revoked_at attribute to the specific time.
  end

  def to_bearer_token
    # Returns an instance of the Rack::OAuth2::AccessToken::Bearer 
    # initialized with the next hash:
    #   access_token: '',    # - required
    #   refresh_token: '',   # - optional
    #   token_type: '',      # - required
    #   expires_in: '',      # - required
    #   scope: ''            # - optional
  end
end
```

You can take a look at the [Grape OAuth2 mixins](https://github.com/nbulaj/grape_oauth2/tree/master/lib/grape_oauth2/mixins) to understand what they are doing and what they are returning.

#### ResourceOwner

As was said before, Resource Owner class (`User` model for example) must contain only one class method (in case of Password Authorization Grant): `self.oauth_authenticate(client, username, password)`.

```ruby
class User
  def self.oauth_authenticate(client, username, password)
    # Returns an instance of the User class with matching username
    # and password. If there is no such User or password doesn't match
    # then returns nil.
  end
end
```

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

    # Mount default Grape OAuth2 Token endpoint
    mount GrapeOAuth2::Endpoints::Token

    # Mount default authorization endpoint
    # mount GrapeOAuth2::Endpoints::Authorize
   
    # ...
  end
end
```

That's all!

Available routes:

```
POST /oauth/token
POST /oauth/revoke
```

### Hey, I wanna control all the authentication process!

If you need to do some special things (check if `client_id` starts with _'MyAPI'_ word for example), then you can just override default authentication methods in models (only if you are using gem mixins, in other cases you **MUST** write them by yourself):

```ruby
# app/models/application.rb
class Application < ApplicationRecord
  include GrapeOAuth2::ActiveRecord::Client
  
  class << self
    def self.authenticate(key, secret, need_secret = true)
      # My custom condition for successful authentication
      return nil unless key.start_with?('MyAPI')

      if need_secret
        find_by(key: key, secret: secret)
      else
        find_by(key: key)
      end
    end
  end
end
```

Besides, you can customize all the OAuth2 Token flow with your own API endpoint and do some stuffs with the help of the Grape OAuth2 gem.
Just create a common Grape API class, set optional OAuth2 params and process the request with the `GrapeOAuth2::Generators::Token` class:

```ruby
# api/oauth2.rb
module MyAPI
  class OAuth2 < Grape::API
    helpers GrapeOAuth2::Helpers::OAuthParams

    namespace :oauth do
      params do
        use :oauth_token_params
      end

      post :token do
        token_response = GrapeOAuth2::Generators::Token.generate_for(env) do |request, response|
          # Custom client authentication
          client = Application.find_by(key: request.client_id, active: true)
          request.invalid_client! unless client

          # Custom resource owner (User model) authentication
          resource_owner = User.find_by(username: request.username)
          request.invalid_grant! if resource_owner.nil? || resource_owner.inactive?

          # Create an AccessToken for the client and resource_owner
          token = AccessToken.create_for(client, resource_owner)
          response.access_token = token.to_bearer_token
        end

        # If request is successful, then return it
        status token_response.status

        token_response.headers.each do |key, value|
          header key, value
        end

        body token_response.access_token
      end
      
      desc 'OAuth 2.0 Token Revocation'

      params do
        requires :token, type: String, desc: 'The token that the client wants to get revoked'
        optional :token_type_hint, type: String, 
                                   values: %w(access_token refresh_token),
                                   default: 'access_token',
                                   desc: 'A hint about the type of the token submitted for revocation'
      end

      post :revoke do
       # ...
      end
    end
  end
end
```

## Example App

Take a look at the [sample application](https://github.com/nbulaj/grape_oauth2/tree/master/spec/dummy) in the "spec/dummy" project directory.

## Contributing

You are very welcome to help improve grape_oauth2 if you have suggestions for features that other people can use.

To contribute:

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
