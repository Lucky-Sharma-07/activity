Rails.application.routes.draw do
  resources :timetrackers
  post 'timetrackers/details'
  get 'timetracke/userWebDetails', to: 'timetrackers#user_web_details'
  get 'pages/home'
  get 'pages/restricted'
  devise_for :users

end
