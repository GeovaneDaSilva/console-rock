require "httpi"
require "ms_graph/errors"

# :nodoc
module MsGraph
  # :nodoc
  class DataUpdater
    GRAPH_HOST = "https://graph.microsoft.com".freeze

    def initialize(api_name, credential_id, account_app_id, skip_query = nil)
      # TODO: I still want this to be a set config var somewhere instead of having to initialize it
      # every time I run this
      @api = {
        App.where(report_template: "secure_score").first.id    => {
          url: "/v1.0/security/secureScores",
          process: "secure_score", query: {}, allFirstTime: false
        },
        App.where(report_template: "directory_audit").first.id => {
          url: "/v1.0/auditLogs/directoryAudits",
          process: "directory_audit", query: {}, allFirstTime: true
        },
        App.where(report_template: "signin").first.id          => {
          url: "/v1.0/auditLogs/signIns",
          process: "signin", query: {}, allFirstTime: true
        },
        App.where(report_template: "risk_detection").first.id  => {
          url:          "/v1.0/identityProtection/riskDetections",
          process:      "risk_detection",
          query:        {},
          allFirstTime: true
        },
        -1                                                     => {
          url: "/v1.0/security/secureScoreControlProfiles",
          process: "secure_score_profile", query: {}, allFirstTime: true
        }
      }

      @call = api_name
      @cred = Credential.find(credential_id)
      @account_app_id = account_app_id

      last_updated = AccountApp.find(account_app_id).last_pull unless @call == -1

      if !last_updated.nil? && skip_query.nil?
        # 30 minute lag before events are reported
        case @api[@call][:process]
        when "directory_audit"
          @api[@call][:query] = {
            "$filter": "activityDateTime ge #{[last_updated - 30.minutes, 1.month.ago].max.to_s(:iso8601)}"
          }
        when "signin"
          @api[@call][:query] = {
            "$filter": "createdDateTime ge #{7.days.ago.to_s(:iso8601)}"
          }
        when "secure_score"
          @api[@call][:query] = { "$top": 1 }
        end
      end
    rescue ActiveRecord::RecordNotFound
      @cred = nil
    end

    def call
      return if @cred.nil?
      return unless @cred.customer.customer?
      return if @cred.customer.billing_account.actionable_past_due?
      return if PIPELINE_TRIALS.include?(@cred.customer.parent.id) && !@call == 20

      # Rails.logger.info("Pulling latest data from MS Graph API")

      events = ms_graph_events || []

      ServiceRunnerJob.set(queue: :utility)
                      .perform_later(
                        "MsGraph::SaveTemplates::#{@api[@call][:process].camelize}",
                        @call, @cred.id, @cred.customer, events
                      )

      if @api[@call][:process] == "directory_audit" && (Time.zone.now.hour % 4).zero?
        ServiceRunnerJob.perform_later("MsGraph::Services::EmailRuleRunner", @cred.id)
        # elsif @api[@call][:process] == "signin"
        #   ServiceRunnerJob.set(wait: rand(45..75).minutes).perform_later(
        #     "MsGraph::DataUpdater", @call, @cred.id, @account_app_id
        #   )
      end
      # if job is taking too long and DB callbacks/validations not needed, change save code to below
      # Apps::Office365Result.transaction do
      #   Apps::Office365Result.import %i[detection_date app_id value value_type customer_id details
      #                               ms_graph_credential_id verdict], db_events
      # end
    end

    private

    def make_api_call(endpoint, token, params = nil)
      headers = {
        Authorization: "Bearer #{token}"
      }

      query = params || {}

      request = HTTPI::Request.new
      request.url = "#{GRAPH_HOST}#{endpoint}" # TODO: change to URI?
      request.headers = headers
      request.query = query

      begin
        resp = HTTPI.get(request)
      rescue Errno::ECONNRESET
        raise MsGraph::ConnectionPeerResetError
      end

      resp
    end

    def ms_graph_events
      token = CredentialUpdater.new.call(@cred)
      return [] unless @api.include? @call

      resp = make_api_call @api[@call][:url], token, @api[@call][:query]

      unless resp.code == 200
        Rails.logger.error("MS Graph API failure code #{resp.code} with message #{JSON.parse(resp.raw_body)}")
        error = JSON.parse(resp.raw_body)
        ServiceRunnerJob.perform_later("MsGraph::Services::MsPullError", error, @call, @cred)
        return []
      end

      JSON.parse(resp.raw_body)["value"] || []
    end
  end
end
