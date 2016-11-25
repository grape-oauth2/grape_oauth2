# Common config across all the ORMs
Grape::OAuth2.configure do |config|
  config.client_class_name = 'Application'
  config.access_token_class_name = 'AccessToken'
  config.resource_owner_class_name = 'User'
  config.access_grant_class_name = 'AccessCode'

  config.realm = 'Custom Realm'

  config.allowed_grant_types << 'refresh_token'
end
