Rubygems::Application.routes.draw do
  root to: "home#show"

  resources :projects, only: [:show, :index], constraints: {id: /[^\/]+/}

  resources :versions, path: :gems, only: [:show], constraints: {id: /[^\/]+/} do
    get :browse, path: "browse(/*path)", on: :member, constraints: {format: false}
    get :raw, path: "raw(/*path)", on: :member, constraints: {format: false}
  end
end
