Rails.application.routes.draw do
  # Mount Sidekiq web interface
  mount Sidekiq::Web => '/sidekiq'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root 'dashboard#index'

  # Dashboard actions
  post 'videos/:id/approve', to: 'dashboard#approve_video', as: :approve_video
  post 'videos/:id/upload', to: 'dashboard#upload_video', as: :upload_video
  post 'generate_script', to: 'dashboard#generate_script', as: :generate_script
  post 'crawl_data', to: 'dashboard#crawl_data', as: :crawl_data

  get 'dashboard/job_progress', to: 'dashboard#job_progress'
end
