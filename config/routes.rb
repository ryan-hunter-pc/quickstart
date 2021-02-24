Rails.application.routes.draw do
  root to: 'marketing#index'

  resource :dashboard, only: [:show]
end
