Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :feefo, only: [:update, :edit]
  end
end
