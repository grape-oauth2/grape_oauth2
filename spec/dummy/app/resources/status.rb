module Twitter
  module Resources
    class Status < Grape::API
      resources :status do
        get do
          { value: 'Nice day!' }
        end
      end
    end
  end
end
