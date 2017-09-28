Rails.application.routes.draw do
  resources :templates
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :submissions do
    resource :check
  end
  resources :assignments

  resource :graph
end
