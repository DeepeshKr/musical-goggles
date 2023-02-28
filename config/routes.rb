Rails.application.routes.draw do
  resources :events
  devise_for :users,
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }
  
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'health#index'
  get '/current_user', to: 'current_user#index'

  namespace :api do
    resources :posts
    resources :events
    post '/upload_file', to: 'events#import'
  end

end
