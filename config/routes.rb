Rails.application.routes.draw do
  get 'places/index'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  get 'working/users', to: 'users#working_users'
  
  # ログイン機能
  get    '/login', to: 'sessions#new'      #ログインページへ
  post   '/login', to: 'sessions#create'   #ログイン(セッション作成)
  delete '/logout', to: 'sessions#destroy' #ログアウト(セッション削除)
  
  resources :users do
    collection { post :import }
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      
    end
    resources :attendances, only: :update
  end
  
  resources :places
end
