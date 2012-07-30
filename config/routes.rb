Rubygems::Application.routes.draw do
  root to: "home#show"

  resources :versions, path: :gems, only: [:index, :show], constraints: {id: /[^\/]+/} do
    get :other, on: :member
    get :browse, path: "browse(/*path)", on: :member, constraints: {format: false}
    get :raw, path: "raw(/*path)", on: :member, constraints: {format: false}
    get "docs/(*path)", to: "docs#show", as: :docs
    get "docs_status", to: "docs#status", as: :docs_status
  end
end
