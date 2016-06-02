module Twitter
  module Resources
    class Status < Grape::API
      resources :status do
        get do
          access_token_required!

          { value: 'Nice day!' } #, current_user: current_resource_owner.username }
        end
      end
    end
  end
end
