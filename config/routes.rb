Rails.application.routes.draw do
  resources :experiment_users do
    resources :experiments
  end
  resources :templates do
    member do
      post 'rpcsr_check'
    end
    resources :template_lines
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :submissions do
    resource :check
  end
  resources :assignments

  resources :current_assignments do
    member do
      get 'moodle'
    end
  end

end
