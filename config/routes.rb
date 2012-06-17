RubygemsOrg::Application.routes.draw do
  root to: "search#new"

  resources :projects, only: [:show, :index]

  resources :versions, path: :gems, only: [:show], constraints: {id: %r{[^/]+}} do
    get :browse, path: "browse(/*path)", on: :member
  end
end
