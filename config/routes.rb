Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :subscriptions do
      get :cancel, on: :member
    end
  end
end
