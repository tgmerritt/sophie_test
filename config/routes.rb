Rails.application.routes.draw do
  resources :conversations
  root to: 'visitors#index'
end
