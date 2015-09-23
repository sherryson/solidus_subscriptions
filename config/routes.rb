Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :subscriptions, except: [:show, :destroy] do
      member do
        put :cancel
        put :renew
        put :skip
        put :undo_skip
        get :credit_card
        post :credit_card
      end
    end
  end

  namespace :api, defaults: { format: 'json' } do
    resources :subscriptions, except: [:index, :create, :new, :destroy] do
      member do
        put :skip_next_order
        put :undo_skip_next_order
        put :pause
        put :resume
        post :create_address
        put :update_address
        put :select_address
        put :cancel
        post :create_credit_card
      end
      resources :subscription_items
    end
  end
end
