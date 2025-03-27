Rails.application.routes.draw do
  get "metadata_formats/:id/systems", to: "metadata_formats#systems", as: "metadata_format_instances"
  resources :metadata_formats

  # Defines the root path route ("/")
  root "home#index"

  get "browser", to: "browser#index"
  get "about", to: "about#index"
  get "help", to: "help#index"
  get "search", to: "search#index", as: "search"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # STATISTICS
  get "statistics", to: "statistics#index"
  get "statistics/clear_cache", to: "statistics#clear_cache",as: "clear_statistics_cache"
  get "statistics/by-continent", to: "statistics#by_continent"
  get "statistics/by-country", to: "statistics#by_country"
  get "statistics/by-platform", to: "statistics#by_platform"

  # CONSOLE & ADMIN
  get "admin", to: "admin#index"
  if ENV["ALLOW_TEST_USER_ACCOUNTS_WITHOUT_VERIFICATION"] == "true"
    get "admin/authenticate_as", to: "admin#authenticate_as", as: "authenticate_as"
  end
  get "deduplication", to: "deduplication#index"
  get "deduplication/deduplicate", to: "deduplication#deduplicate", as: "deduplicate"

  # BACKGROUND JOBS
  constraints Passwordless::Constraint.new(User, if: -> (user) { user.has_role?(:administrator) }) do
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  get "generators/:id/systems", to: "generators#systems", as: "generator_instances"
  resources :generators


  passwordless_for :users
  get "/dashboard", to: "users#dashboard", as: "user_root"
  get "/users/:id/generate_api_key", to: "users#generate_api_key", as: "generate_api_key"
  get "/users/:id/revoke_access", to: "users#revoke_access", as: "revoke_access"
  get "/users/:id/restore_access", to: "users#restore_access", as: "restore_access"
  get "/users/:id/authorised_systems", to: "users#authorised_systems", as: "authorised_systems"
  get "/users/:id/systems_requiring_review", to: "users#systems_requiring_review", as: "systems_requiring_review"
  resources :users

  get "roles/:id/users", to: "roles#users", as: "role_instances"
  resources :roles

  get "countries/:id/systems", to: "countries#systems", as: "country_instances"
  get "countries/geometries", to: "countries#geometries", as: "country_geometries"
  resources :countries

  get "platforms/:id/systems", to: "platforms#systems", as: "platform_instances"
  resources :platforms

  # ORGANISATIONS
  post "/organisations/add_user_as_agent", to: "organisations#add_user_as_agent"
  get "/organisations/autocomplete", to: "organisations#autocomplete", as: "autocomplete_org_link"
  get "/organisations/search", to: "organisations#search", as: "organisation_search"
  get "organisations/responsible_parties", to: "organisations#responsible_parties", as: "responsible_parties"
  get "organisations/:id/ownerships", to: "organisations#ownerships", as: "organisation_ownerships"
  get "organisations/:id/responsibilities", to: "organisations#responsibilities", as: "organisation_responsibilities"
  get "organisations/:id/make_rp", to: "organisations#make_rp", as: "make_rp"
  get "organisations/:id/make_rp_for_country", to: "organisations#make_rp_for_country", as: "make_rp_for_country"
  get "organisations/:id/remove_rp_status", to: "organisations#remove_rp_status", as: "remove_rp_status"
  resources :organisations

  # SYSTEMS
  get "/systems/:id/label", to: "systems#label", as: "label"
  get "/systems/:id/network_check", to: "systems#network_check", as: "network_check"
  # get '/systems/autocomplete', to: 'systems#autocomplete', as: 'autocomplete_system_link'
  get "/systems/search", to: "systems#search", as: "system_search"
  get "/systems/:id/check_url", to: "systems#check_url", as: "check_website"
  post "/systems/add_repo_id", to: "systems#add_repo_id"
  get "/systems/:id/process_as_duplicate", to: "systems#process_as_duplicate", as: "process_as_duplicate"
  get "/systems/:id/mark_reviewed", to: "systems#mark_reviewed", as: "mark_reviewed"
  get "/systems/:id/set_record_verified", to: "systems#set_record_verified", as: "set_record_verified"
  get "/systems/:id/set_record_archived", to: "systems#set_record_archived", as: "set_record_archived"
  get "/systems/:id/set_record_draft", to: "systems#set_record_draft", as: "set_record_draft"
  get "/systems/:id/set_record_awaiting_review", to: "systems#set_record_awaiting_review", as: "set_record_awaiting_review"
  get "/systems/:id/set_record_under_review", to: "systems#set_record_under_review", as: "set_record_under_review"
  get "/systems/:id/get_thumbnail", to: "systems#get_thumbnail", as: "get_thumbnail"
  get "/systems/:id/remove_thumbnail", to: "systems#remove_thumbnail", as: "remove_thumbnail"
  get "/systems/:id/check_oai_pmh_formats", to: "systems#check_oai_pmh_formats", as: "check_oai_formats"
  get "/systems/:id/check_oai_pmh_identify", to: "systems#check_oai_pmh_identify", as: "check_oai_identify"
  get "/systems/:id/check_oai_pmh_combined", to: "systems#check_oai_pmh_combined", as: "check_oai_combined"
  get "/systems/:id/auto_curate", to: "systems#auto_curate", as: "auto_curate"
  post "/systems/authorise_user", to: "systems#authorise_user", as: "authorise_user"
  post "/systems/suggest_new_system", to: "systems#suggest_new_system", as: "suggest_new_system"
  # post '/systems/add_new_user_and_authorise', to: 'systems#add_new_user_and_authorise'
  resources :systems

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  get "errors/not_found"
  get "errors/internal_server_error"
  get "errors/forbidden"
  match "/404", :to => "errors#not_found", :via => :all, as: "error_404"
  match "/500", :to => "errors#internal_server_error", :via => :all, as: "error_500"
  match "/403", :to => "errors#forbidden", :via => :all, as: "error_403"
end
