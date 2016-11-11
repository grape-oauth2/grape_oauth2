module GrapeOAuth2
  module Mongoid
    module AccessGrant
      extend ActiveSupport::Concern

      included do
        include ::Mongoid::Document
        include ::Mongoid::Timestamps

        # To be defined!
      end
    end
  end
end
