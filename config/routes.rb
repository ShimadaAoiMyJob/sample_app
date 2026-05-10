Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get "help",to:'static_pages#help' #url は/help static_pagesはコントローラ名.ほぼ内容が固定のページ用
  get "about",to:'static_pages#about' 
  #/aboutにアクセスされたらstaticpagesコントローラのaboutアクションを実行
  #これだけでabout_pathが作成される
  get "contact",to:'static_pages#contact'
  #これって,static_pages/aboutじゃないのはなんで? 
  #=> #はコントローラとアクションをつなぐ./はファイルの場所
  get "signup",to: "users#new"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "static_pages#home"
  # Defines the root path route ("/")
  # root "articles#index"
  resources :users

  get "/login", to:"sessions#new"
  post "/login", to:"sessions#create"
  delete "/logout",to:"sessions#destroy"

  resources :account_activations, only: [:edit]
  resources :password_resets, only:[:new,:create,:edit,:update]
  resources :microposts,   only:[:create,:destroy]
  get "/microposts", to: "static_pages#home"
end
