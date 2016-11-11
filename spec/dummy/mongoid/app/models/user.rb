class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String
  field :password, type: String

  def self.oauth_authenticate(_client, username, password)
    find_by(username: username, password: password)
  end
end
