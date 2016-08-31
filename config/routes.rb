Rails.application.routes.draw do
  root 'certificate_authorities#index'
  resources :certificate_authorities
  resources :certificates do
    get 'new/csr' => 'certificates#new_from_csr', :on => :collection
    post 'new/csr' => 'certificates#create_from_csr', :on => :collection
    post :revoke, :on => :member
  end
  resources :users
  get 'login' => 'authentication#login'
  get 'auth/:provider/callback' => 'authentication#callback'
  get 'join/:invite_token' => 'authentication#join', :as => 'join'
  delete 'logout' => 'authentication#logout'
end
