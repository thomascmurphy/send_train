TrainToSend::Application.routes.draw do

  get 'home/index'

  devise_for :users, controllers: { sessions: "users/sessions" }

  authenticate :user do
    resources :climbs do
      get "delete"

      resources :attempts
    end
    get 'quick_send', to: 'climbs#quick_new'
    post 'quick_send', to: 'climbs#quick_create'

    resources :workouts do
      get "delete"
    end

    resources :microcycles do
      get "delete"
    end

    resources :mesocycles do
      get "delete"
    end

    resources :macrocycles do
      get "delete"
    end

    resources :events do
      get "delete"
      get "complete"
    end
    get 'gym_session', to: 'events#gym_session_new'
    post 'gym_session', to: 'events#gym_session_create'

    get 'profile', to: 'profile#show'
    get 'profile/edit', to: 'profile#edit'
    patch 'profile', to: 'profile#update'
  end

  get 'comment', to: 'comments#new'
  post 'comment', to: 'comments#create'

  root to: "home#index"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
