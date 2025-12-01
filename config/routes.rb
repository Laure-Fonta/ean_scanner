Rails.application.routes.draw do
  root "scanner#index"

  post "scan_ean", to: "scanner#scan", as: :scan_ean

  resources :suppliers, only: [:index, :show] do
    post :import_items, on: :member
  end

  resources :inventories, only: [:index, :show, :new, :create] do
    member do
      get  :export_found
      get  :export_not_found
      patch :archive
    end
  end
end
