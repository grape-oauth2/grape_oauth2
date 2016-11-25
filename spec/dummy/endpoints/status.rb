module Twitter
  module Endpoints
    class Status < Grape::API
      before do
        access_token_required!
      end

      resources :status do
        get do
          { value: 'Nice day!', current_user: current_resource_owner.username }
        end

        get :single_scope, scopes: [:read] do
          { value: 'Access granted' }
        end

        get :multiple_scopes, scopes: [:read, :write] do
          access_token_required!

          { value: 'Access granted' }
        end
      end
    end
  end
end
