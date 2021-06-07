# :nodoc
module AppActionable
  extend ActiveSupport::Concern

  included do
    before_action :valid_action?
  end

  private

  def valid_action?
    head :not_found if action.blank?
  end

  def app
    @app ||= App.find(params[:app_id])
  end

  def action
    @action ||= app.actions[params[:app_action]]
  end

  def broadcast_message
    {
      type:    "app_action",
      payload: {
        app_id: app.id, action: params[:app_action]
      }
    }
  end
end
