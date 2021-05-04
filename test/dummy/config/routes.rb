Rails.application.routes.draw do
  resources :posts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  put "/known/get", to: "home#get_action"
  put "/known/put", to: "home#put_action"
  patch "/known/patch", to: "home#patch_action"
  delete "/known/delete", to: "home#delete_action"
  post "/known/post", to: "home#post_action"

  root "home#index"
end
