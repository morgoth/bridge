Bridge::Application.routes.draw do
  # bridge

  resource :account
  resources :tables, :only => [:index, :show, :create]
  resources :users, :only => [] do
    resources :boards, :only => [:index, :show]
  end

  # ajax api

  namespace :ajax do
    resources :tables, :only => [:show] do
      resources :messages, :only => [:create]
      resources :bids, :only => [:create]
      resources :cards, :only => [:create]
      resources :claims, :only => [:create] do
        member do
          put :accept
          put :reject
        end
      end
      resource :player, :only => [:create, :destroy] do
        put :start
        put :reset
      end
    end
  end

  root :to => "tables#index"
end
