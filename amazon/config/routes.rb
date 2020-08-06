Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'amazon#index'
  get '/secret' => 'amazon#secret'
  get '/calc' => 'amazon#calc'
  get '/stocker' => 'stocks#create'
end
