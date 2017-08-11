Rails.application.routes.draw do
  get 'welcome/index'

  resources :result

  root 'welcome#index'

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end
end
