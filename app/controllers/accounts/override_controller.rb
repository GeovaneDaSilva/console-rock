module Accounts
  # Override controller
  class OverrideController < AuthenticatedController
    helper_method :app_results

    def index
      authorize current_account, :perform_override_actions?

      @app = ::App.find(params[:app_id])
    end

    def update
      authorize current_account, :perform_override_actions?

      app_result = ::Apps::Result.find(params[:id])
      params[:actions].each do |key, value|
        if key == "details"
          dets = change_details(app_result["details"], value.permit!.to_h)
          app_result.assign_attributes(details: dets)
        else
          app_result[key] = value
        end
      end
      app_result.save

      flash[:notice] = "Result updated"

      redirect_back fallback_location: root_url
    end

    private

    def app_results
      @app_results ||= ::Apps::Result.find(params[:app_results])
    end

    # Find appropriate value in the hash and make change.
    # <new_details> needed because cannot change hash during iteration
    def change_details(existing_details, changes_hash)
      new_details = existing_details.dup
      changes_hash.each do |ky, val|
        key = ky.to_s
        if val.is_a?(Hash)
          new_details[key] = change_details(existing_details[key], val) if existing_details.include?(key)
        else
          new_details[key] = val
        end
      end
      new_details
    end
  end
end
