Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :subscriptions do
      get :cancel, on: :member
    end
  end

  namespace :api, defaults: { format: 'json' } do          
    resources :subscriptions do
      member do
        get :skip_next_order
        get :undo_skip_next_order
      end
    end
    resources :subscription_items
  end  
end
