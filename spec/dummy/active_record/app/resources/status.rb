module Twitter
  module Resources
    class Status < Grape::API
      resources :status do
        get do
          access_token_required!

          { value: 'Nice day!', current_user: current_resource_owner.username }
        end

        get :single_scope do
          access_token_required! :read

          { value: 'Access granted' }
        end

        get :multiple_scopes do
          access_token_required! :read, :write

          { value: 'Access granted' }
        end
      end
    end
  end
end
