Rails.application.routes.draw do
  root to: 'visitors#index'

  # Authentication
  resources :passwords, controller: "passwords", only: [:create, :new]
  resource :session, controller: "sessions", only: [:create]
  resources :users, controller: "users", only: [:create] do
    resource :password,
      controller: "passwords",
      only: [:create, :edit, :update]
  end
  get "/sign_in" => "sessions#new", as: "sign_in"
  delete "/sign_out" => "sessions#destroy", as: "sign_out"
  get "/sign_up" => "users#new", as: "sign_up"

  # Top-level static pages
  get "/*id" => 'pages#show',
      as: :page,
      format: false,
      constraints: { id: /(#{HighVoltage.page_ids.join('|')})/ }
end
