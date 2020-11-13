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
    end
    resources :attendances, only: :update do
      member do
        delete "d"
        get 'edit_overtime_request'
        patch 'update_overtime_request'
        patch 'update_final_one_month_request'
      end
      collection do
        get 'edit_overtime_notice'
        patch 'update_overtime_notice'
        get 'edit_one_month_request'
        patch 'update_one_month_request'
        get 'edit_one_month_notice'
        patch 'update_one_month_notice'
        get 'edit_final_one_month_notice'
        patch 'update_final_one_month_notice'
        get 'log'
      end
    end
  end
  
  resources :places
end
