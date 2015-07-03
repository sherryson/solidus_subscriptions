Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :subscriptions do
      member do 
        get :cancel
        get :renew
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    resources :subscriptions do
      member do
        put :skip_next_order
        put :undo_skip_next_order
        post :create_address
        put :update_address
        put :cancel
      end
    end
    resources :subscription_items
  end
end
