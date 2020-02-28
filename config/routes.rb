Rails.application.routes.draw do
  resources :speaks
  resources :hounds
  resources :conversations
  resources :fmauths
  resources :webhooks, only: :create
  root to: 'visitors#index'
end
