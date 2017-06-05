Rails.application.routes.draw do
  get 'welcome/index'

  resources :result

  root 'welcome#index'
end
