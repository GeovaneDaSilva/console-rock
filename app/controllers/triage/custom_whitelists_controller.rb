module Triage
  # Custom whitelisting of app results
  class CustomWhitelistsController < AuthenticatedController
    helper_method :whitelist_path, :account, :query_params, :triage_path, :app, :fields, :path, :display

    def show
      authorize scope, :triage?
      authorize([:accounts, app], :whitelistable?)
    end

    def create
      authorize scope, :triage?
      authorize([:accounts, app], :whitelistable?)

      logic_params = params.dup
                           .except(:utf8, :app_id, :controller, :commit, :action, :account_id, :apply_to_all)
                           .reject { |_key, value| value.blank? }
      custom_config_list["list"] << logic_params.permit!.to_h
      custom_config.assign_attributes(config: custom_config_list)
      params.reject! { |key, value| value.blank? || logic_params.include?(key) }.permit!

      if custom_config.save
        flash[:notice] = "Custom whitelist created"
        destroy_whitelisted_records(custom_config) if params[:apply_to_all]
        redirect_to triage_path(params)
      else
        flash[:error] = "Error creating custom whitelist"
        redirect_back fallback_location: triage_path(params)
      end
    end

    private

    def custom_config_list
      @custom_config_list ||= custom_config.config || { "list" => [] }
    end

    def custom_config
      @custom_config ||= Apps::CustomConfig.where(app: app, account: account).first_or_initialize
    end

    def fields
      @fields ||= get_possible_fields(app_result)
    end

    def app
      @app ||= App.find(params[:app_id])
    end

    def scope
      account
    end

    def destroy_whitelisted_records(config)
      ServiceRunnerJob.perform_later(
        "Apps::Results::CustomDestroyer", config.id, config.account_id, config.app_id
      )
    end

    def app_result
      Apps::Result.find(params[:app_results].first) # TODO: -- fix the whole pipeline so only one
    end

    def account
      @account ||= Account.find(params[:account_id])
    end

    def triage_path(*opts)
      account_triage_path(account, *opts)
    end

    def custom_whitelist_path(*opts)
      account_triage_custom_whitelist_path(account, *opts)
    end

    def query_params
      {
        start_date: params[:start_date], end_date: params[:end_date], search: params[:search],
        app_id: params[:app_id]
      }.reject { |_k, v| v.blank? }
    end

    def get_possible_fields(hash, path_here = [])
      return get_possible_fields(hash["details"]).map { |item| item.join(",") } if hash.is_a?(Apps::Result)

      thingies = []

      # assume only one app result (put in instrucitons)
      hash.keys.each do |one|
        next if hash[one].class == Array # punt for now

        if hash[one].class == Hash
          thingies += get_possible_fields(hash[one], path_here + [one])
        else
          thingies << path_here + [one]
        end
      end

      thingies
    end
  end
end
