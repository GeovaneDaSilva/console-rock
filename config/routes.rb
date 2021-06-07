require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  namespace :administration do
    resources :providers, only: %i[index new create destroy]
    resources :users, only: %i[index edit update] do
      resource :unlock, only: %i[update], module: "users"
      resource :un2fa, only: %i[update], module: "users"
    end
    resources :support_files, only: %i[index]
    resources :plans, except: [:show]
    resources :hunts
    resources :system_hunts_categories
    resources :ttps
    resources :crash_reports, only: %i[index destroy]
    resources :move_customers, only: %i[index edit update]

    resources :agent_releases, except: %i[edit]

    resource :managed_triage, only: %i[show]
    resources :incidents do
      post "export", to: "export", as: "export"
    end

    namespace :logic_rules do
      resources :action_templates
    end
    resources :logic_rules

    resources :panics, only: %i[index show destroy]

    namespace :apps do
      resource :notify, only: %i[create]
    end
    resources :apps

    authenticate :user, (->(u) { u.admin_role }) do
      mount Sidekiq::Web, at: "/sidekiq"
      mount PgHero::Engine, at: "/pghero"
    end

    authenticate :user, ->(u) { u.omnipotent? } do
      mount Flipper::UI.app(Flipper), at: "/flipper"
    end
  end

  get "/administration", to: redirect("/administration/providers")

  namespace :api do
    scope module: :v1, constraints: ApiConstraint.new(version: 1) do
      post "/panic/:id/d1baf4598feabe90a8dd2fc758859e99", to: "panics#create", as: "panic"

      resources :accounts, only: %i[] do
        resource :stats, only: %i[show], module: "accounts"
      end

      resources :cloud_apps, only: %i[] do
        resource :results, only: %i[create], module: "cloud_apps"
      end

      resources :customers, only: %i[show] do
        resources :devices, only: %i[update], module: "customers"
        resources :billable_instances, only: %i[update], module: "customers"
        resources :supports, only: %i[index show], module: "customers"
        resources :apps, only: %i[index], module: "customers" do
          resources :results, only: %i[index], module: "apps"
        end
        get "agent" => "customers/agents#show"
      end

      resources :devices, only: [], module: :devices do
        resources :jobs, only: %i[index] do
          put "start" => "jobs/starts#update", as: "start"
        end

        resources :results, only: [], module: :results do
          resource :resolve, only: %i[update]
          resource :error, only: %i[update]
        end

        resources :apps, only: %i[index show] do
          resource :result, only: [:create], module: :apps
        end

        resources :hunts, only: %i[index show] do
          resource :start, only: [:update], module: :hunts
        end
        resources :hunt_results, only: %i[create]
        resources :crash_reports, only: %i[create]
        resources :inventories, only: %i[create]
        resources :agent_logs, only: %i[create]
        resources :uploads, except: %i[index edit destroy new]
      end

      resources :healthcheck, only: %i[index]

      resources :integrations, only: %i[] do
        resources :app_results, only: %i[index show], module: "integrations"
        resources :authenticate, only: %i[create], module: "integrations"
        resources :billing, only: %i[index], module: "integrations"
        resources :customers, only: %i[index create update], module: "integrations"
        resources :extend_trial, only: %i[create], module: "integrations"
        resources :incidents, only: %i[index show], module: "integrations"
        resources :move_partner, only: %i[create], module: "integrations"
        resources :partners, only: %i[index create update], module: "integrations"
        resources :password_reset, only: %i[create], module: "integrations"
        resources :products, only: %i[index], module: "integrations"
        resources :subscriptions, only: %i[create], module: "integrations"
        resources :usage, only: %i[index], module: "integrations"
      end
    end
  end

  devise_for :users, controllers:
                                  {
                                    registrations: "users/registrations"
                                  }

  resources :searches, only: %i[index]

  post "job_status" => "job_status#show"

  namespace :searches do
    resources :switch_accounts, only: %i[index]
  end

  namespace :analysis do
    resource :url, only: %i[create]
    resource :file, only: %i[create]
  end

  resources :providers, except: %i[edit destroy] do
    resources :users, only: %i[new create edit update destroy],
                      module: "providers", controller: "user_roles"
    resources :moves, only: %i[create], module: "providers"
    post "/extend_trial", to: "providers#extend_trial_days"
  end

  resources :accounts, only: %i[] do
    # account_path is a hack helper method in the authentiated_controller

    post "current" => "accounts/currents#create", as: "current"
    resources :users, only: %i[new create edit update destroy], module: "accounts" do
      resource :invitation, only: [:create], module: "users"
    end

    resources :plans, only: %i[create destroy update], module: "accounts"
    resources :charges, only: %i[show], module: "accounts"
    resources :credit_cards, only: %i[new create], module: "accounts"

    resources :subscriptions, only: %i[create update destroy], module: "accounts"
    resources :api_keys, only: %i[create update destroy], module: "accounts"
    resources :apps, only: %i[index create update], module: "accounts" do
      resource :config, only: %i[update destroy], module: "apps"
    end

    namespace :apps, module: "accounts" do
      resources :incidents, module: "apps" do
        get "whitelist", to: "whitelist", as: "whitelist"
        resource :publish, only: %i[update], module: "incidents"
        resource :notify, only: %i[update], module: "incidents"
        resource :resolve, only: %i[update], module: "incidents"
        resource :remediate, only: %i[show update], module: "incidents"
        post "export", to: "export", as: "export"
      end
      resources :remediations, only: %i[show], module: "apps"
      resources :antivirus_config, only: %i[create index], module: "apps"
      resources :whitelists, only: %i[index], module: "apps" do
        resource :remove, only: %i[create], module: "whitelists"
      end
    end

    namespace :defender, module: "accounts" do
      resource :update, only: %i[create], module: "defender"
      resource :scan, only: %i[create], module: "defender"
    end

    resource :defender, only: %i[show]
    resource :office365, only: %i[show]
    resource :triage, only: %i[show create]
    resources :antivirus_actions, only: %i[index update create], module: "accounts"
    resources :override, only: %i[index update], module: "accounts"
    resources :integrations, only: %i[index], module: "accounts"
    namespace :integrations, module: "accounts" do
      get "cylance" => "/accounts/integrations#cylance"
    end

    namespace :credentials, module: "accounts" do
      resource :test, only: %i[create], module: "credentials"
      resource :job_status, only: %i[show], module: "credentials"
    end
    resources :api_integrations, only: %i[create], module: "accounts"
    resources :credentials, only: %i[create update destroy], module: "accounts"

    resources :notifications, only: %i[create], module: "accounts"
    resources :psa_config, only: %i[create update destroy], module: "accounts"
    resources :psa_customer_map, only: %i[create index update], module: "accounts"
    resources :psa_customer_creation, only: %i[create index], module: "accounts"

    post "psa_customer_map/search" => "accounts/psa_customer_map#search"
    get "psa_customer_map/search" => "accounts/psa_customer_map#search"
    post "psa_customer_map/create_advanced" => "accounts/psa_customer_map#create_advanced"
    delete "psa_customer_map/destroy_advanced" => "accounts/psa_customer_map#destroy_advanced"

    namespace :office365, module: "office365s" do
      resource :user, only: %i[show update]
      resource :export, only: %i[show]
    end

    namespace :triage, module: "triage" do
      resource :whitelist, only: %i[show create]
      resource :custom_whitelist, only: %i[show create update]
      resource :incident, only: %i[show create]
      resource :logic_rule, only: %i[show create]
      namespace :logic_rules do
        resource :evaluate, only: %i[show]
      end
    end

    resources :app_actions, only: %i[create], module: "accounts"
  end

  resources :customers do
    resources :agents, only: %i[index show], module: "customers"
  end

  delete "/cysurance/:account_id" => "cysurance#destroy", as: "cysurance_destroy"
  post "/cysurance/:account_id" => "cysurance#create", as: "cysurance_index"
  get "/cysurance/download_pdf" => "cysurance#download_pdf", as: "cysurance_download_pdf"

  namespace :devices do
    resource :export, only: %i[show]
  end

  resources :devices, only: %i[index show destroy update create] do
    get "inventory" => "devices#inventory"
    post "custom_update" => "devices#custom_update"
    resources :app_actions, only: %i[create], module: "devices"
    resources :updates, only: %i[create], module: "devices"
    resources :restarts, only: %i[create], module: "devices"
    resources :defender_actions, only: %i[update], module: "devices"
    resources :agent_triages, only: %i[create], module: "devices"
    resources :memory_dumps, only: %i[create], module: "devices"
    resources :inventories, only: %i[create], module: "devices"
    resources :purges, only: %i[create], module: "devices"
    resources :uninstalls, only: %i[create], module: "devices"
    resources :agent_logs, only: %i[create index destroy], module: "devices"
    resources :isolation, only: %i[update], module: "devices"
    resources :hunts, only: %i[index], module: "devices" do
      resources :results, only: %i[destroy], module: "hunts"
    end

    resources :apps, only: %i[destroy], module: "devices" do
      resources :results, only: %i[destroy], module: "apps"
      resource :config, only: %i[update destroy], module: "apps"
    end

    namespace :r, module: "devices/r" do
      resource :breach, only: %i[show]
      resource :timeline, only: %i[show]

      resources :hunts, only: %i[show]
    end

    namespace :defender, module: "devices/defender" do
      resource :update, only: %i[create]
      resource :scan, only: %i[create]
    end

    resource :triage, only: %i[show create], module: "devices"

    namespace :triage, module: "devices" do
      resource :whitelist, only: %i[show create], module: "triage"
      resource :incident, only: %i[show create], module: "triage"
      resource :logic_rule, only: %i[show create], module: "triage"
      namespace :logic_rules do
        resource :evaluate, only: %i[show]
      end
    end
  end
  resources :firewalls, only: %i[destroy]

  resources :groups
  resources :jobs
  resources :polled_tasks, only: %i[show]
  resources :integrations, only: %i[index]

  namespace :hunts, module: "hunts" do
    resources :feeds
    namespace :on_demand, module: :on_demand do
      resource :processname, only: %i[create]
      resource :filename, only: %i[create]
      resource :filehash, only: %i[create]
      resource :url, only: %i[create]
    end
  end

  resources :hunts do
    resources :manual_runs, only: %i[create update], module: "hunts"
  end

  namespace :uploads do
    resources :accounts, only: [] do
      resources :uploads, controller: "account_uploads", except: %i[index edit]
    end

    resources :providers, only: [] do
      resources :uploads, controller: "provider_uploads", except: %i[index edit]
    end

    resources :support_file_uploads, except: %i[index edit]
    resources :system_hunt_file_uploads, except: %i[index edit destroy]
    resources :analysis_uploads, except: %i[index edit destroy]
  end

  namespace :r, module: :r do
    resource :breaches, only: %i[show]
    resource :executive_summary, only: %i[show]
    resource :threat_map, only: %i[show]
  end

  resources :onboarding, module: :onboarding, only: [] do
    resource :customer, only: %i[new create]
    resource :agent, only: %i[show]
    resource :complete, only: [:show]
    resource :skip, only: [:create]
  end

  get "/tos" => "statics#tos"
  get "/qr" => "users/two_factor#show"
  post "/qr" => "users/two_factor#create"
  delete "/qr" => "users/two_factor#destroy"

  get "/ms_graph_auth/signin"
  get "/ms_graph_auth/signout"
  post "/sentinelone_auth/create"
  delete "/sentinelone_auth/destroy"
  post "/webroot_auth/create"
  delete "/webroot_auth/destroy"
  post "/cylance_auth/create"
  delete "/cylance_auth/destroy"
  post "/bitdefender_auth/create"
  delete "/bitdefender_auth/destroy"
  post "/ironscales_auth/create"
  delete "/ironscales_auth/destroy"
  post "/deep_instinct_auth/create"
  delete "/deep_instinct_auth/destroy"
  post "/hibp_auth/create"
  delete "/hibp_auth/destroy"
  post "/dns_filter_auth/create"
  delete "/dns_filter_auth/destroy"
  post "/sophos_auth/create"
  delete "/sophos_auth/destroy"
  post "/passly_auth/create"
  delete "/passly_auth/destroy"
  post "/duo_auth/create"
  post "/duo_auth/connection_test"
  delete "/duo_auth/destroy"
  post "/cisco_umbrella_auth/create"
  delete "/cisco_umbrella_auth/destroy"

  match "/auth/callback", to: "ms_graph_auth#callback", via: %i[get post]

  get "/accounts/:account_id/cloud_apps", to: redirect("/accounts/%{account_id}/office365")
  get "/accounts/:account_id/cloud_apps", to: redirect("/accounts/%{account_id}/office365")
  get "/cloud_apps/:account_id/r/breach", to: redirect("/r/breaches?switch_account_id=%{account_id}")
  get "sales" => "accounts#sales", as: "sales"
  root "accounts#index"
end
