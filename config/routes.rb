Rails.application.routes.draw do
	devise_scope :user do
		root to: 'application#index'
		get "users/sign_in" => 'application#index'
		get "users/sign_up" => "application#index", as: "new_user_registration"
	end
	devise_for :users, controllers: {
		omniauth_callbacks: "users/omniauth_callbacks"
  	}, skip: [:registrations, :passwords]
  	root 'application#index'
	get 'people'								=> 'people#index', :as => :users_index
  	get 'people/year/:year/:month'				=> 'people#index'
  	get 'people/:id/update'						=> 'people#update', :as => :update_user
  	get 'people/pool/:pool_year/:pool_month'	=> 'people#get_pool'
  	get 'people/:id'							=> 'people#show', :as => :user
  	get 'projects/insert'						=> 'projects#insert'
  	get 'projects/update(/:id)'					=> 'projects#update', as: :update_projects
  	get 'clusters'								=> 'clusters#index', as: :clusters_index
	get 'stats'                                 => 'stats#index', :as => :stats_index
	get 'admissions/update'                     => 'people#update_admitted'
end
