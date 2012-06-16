RubygemsOrg::Application.routes.draw do
  root to: "search#new"
  match :search, via: [:get, :post], to: "search#create"
  resources :projects, only: :show
  get "gems/:id.gem", to: "versions#download", as: :download_version
end
