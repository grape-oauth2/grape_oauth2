# Grape OAuth2
[![Build Status](https://travis-ci.org/nbulaj/grape-oauth2.svg?branch=master)](https://travis-ci.org/nbulaj/grape-oauth2)
[![Dependency Status](https://gemnasium.com/nbulaj/grape-oauth2.svg)](https://gemnasium.com/nbulaj/grape-oauth2)
[![Code Climate](https://codeclimate.com/github/nbulaj/grape-oauth2/badges/gpa.svg)](https://codeclimate.com/github/nbulaj/grape-oauth2)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg)](#license)

This gem adds a flexible OAuth2 server authentication to your Grape project.

**Currently under development**.

## Installation

If using bundler, first add 'grape_oauth2' to your Gemfile:

```ruby
gem "grape_oauth2"
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

Main config:

```ruby
GrapeOAuth2.configure do |config|
  # Access Token lifetime
  config.token_lifetime = 2.hours

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

`resource_owner_class` must have a `self.oauth_authenticate(client, username, password)` method, that returns an instance
of the class if authentication successful (username and password matches for example) and `false` or `nil` in other cases.

```ruby
# app/models/user/rb
class User < ApplicationRecord
  has_secure_password

  def self.oauth_authenticate(_client, username, password)
    user = find_by(username: username)
    return if user.nil?

    user.authenticate(password)
  end
end
```

`client_class`, `access_token_class` and `resource_owner_class` classes must contain a specific set of API (methods),
that are called by the gem. If your models are `ActiveRecord::Base`, then you can include Grape OAuth2 mixins to them:

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

In other case you can write your own classes with the next API:

### Client

You must define relation with `AccessTokens` and authentication method (`self.authenticate(key, secret)`).

### AccessToken

 You must define relations with `Client` and `ResourceOwner` (`User` for example) and the next methods:

* `self.create_for(client, resource_owner)`
* `self.authenticate(token)`
* `expired?`
* `expires_in_seconds`
* `revoked?`
* `revoke!(clock = Time)`
* `accessible?`
* `to_bearer_token`

You can take a look at the Grape OAuth2 mixins to understand what they are doing and what they must return.

## Usage

First you need to configure gem as described above. 

If you want to use gem default OAuth2 endpoint, just mount it to your Grape API module:

```ruby
module Twitter
  class API < Grape::API
    version 'v1', using: :path
    format :json
    prefix :api

    helpers GrapeOAuth2::Helpers::AccessTokenHelpers

    # What to do if somebody will request an API with access_token
    use Rack::OAuth2::Server::Resource::Bearer, 'OAuth API' do |request|
      AccessToken.authenticate(request.access_token) || request.invalid_token!
    end

    # Moune default Grape OAuth2 Token endpoint
    mount GrapeOAuth2::Endpoints::Token
   
    # ...
  end
end
```

Also you can customize all the OAuth2 Token flow with your own API endpoint and help of Grape OAuth2 gem:

```ruby
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
          application = Application.where(key: request.client_id, active: true)
          request.invalid_client! unless application

          resource_owner = User.find_by(username: request.username)
          request.invalid_grant! if resource_owner.nil? || resource_owner.inactive?

          token = AccessToken.create_for(application, resource_owner)
          response.access_token = token.to_bearer_token
        end

        # Status
        status token_response.status

        # Headers
        token_response.headers.each do |key, value|
          header key, value
        end

        # Body
        body token_response.access_token
      end
    end
  end
end
```

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
