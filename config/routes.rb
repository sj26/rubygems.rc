RubygemsOrg::Application.routes.draw do
  root to: "search#new"

  resources :projects, only: [:show, :index]

  resources :versions, path: :gems, only: [:show], constraints: {id: /[^\/]+/} do
    get :browse, path: "browse(/*path)", on: :member, constraints: {format: false}
    get :raw, path: "raw(/*path)", on: :member, constraints: {format: false}
  end
end
