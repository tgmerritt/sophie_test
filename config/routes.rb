Rails.application.routes.draw do
  resources :conversations
  resources :fmauths
  root to: 'visitors#index'
end
