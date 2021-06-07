module Hunts
  # :nodoc
  class FeedsController < AuthenticatedController
    include Pagy::Backend

    before_action :feeds, only: %i[index]
    before_action :feed, only: %i[show edit update destroy]
    before_action :groups, only: %i[new edit]

    after_action :refresh_feed_results!, only: %i[create update]

    def index
      authorize current_account, :view_threat_hunts?
      @pagination, @feeds = pagy feeds
    end

    def show
      authorize current_account, :view_threat_hunts?
      @pagination, @results = pagy feed.feed_results.includes(:hunt).order("created_at DESC")
    end

    def new
      authorize current_account, :can_modify_threat_intel_feeds?

      @system_feed        = Hunts::Feed.new(source: :system_hunts)
      @cymon_feed         = Hunts::Feed.new(source: :cymon)
      @alienvault_feed    = Hunts::Feed.new(source: :alien_vault)
      @reversinglabs_feed = Hunts::Feed.new(source: :reversing_labs)
      @virus_total_feed   = Hunts::Feed.new(source: :virus_total, keyword: "")
    end

    def create
      authorize current_account, :can_modify_threat_intel_feeds?

      @feed = Hunts::Feed.new(feed_params)

      if @feed.save
        flash[:notice] = "New feed added"
        redirect_to hunts_feeds_path
      else
        flash.now[:error] = "Unable to add feed"
        render :new
      end
    end

    def edit
      authorize current_account, :can_modify_threat_intel_feeds?
    end

    def update
      authorize current_account, :can_modify_threat_intel_feeds?

      if feed.update(feed_params)
        flash[:notice] = "Successfully updated feed"
        redirect_to hunts_feeds_path
      else
        flash.now[:error] = "Unable to update feed"
        render :edit
      end
    end

    def destroy
      authorize current_account, :can_modify_threat_intel_feeds?

      flash[:notice] = (feed.destroy ? "Destroyed feed" : "Unable to destroyed feed")

      redirect_to hunts_feeds_path
    end

    private

    def refresh_feed_results!
      ServiceRunnerJob.perform_later(updater_class_name, feed)
    end

    def updater_class_name
      "Hunts::Feeds::#{feed.source.camelize}"
    end

    def feed
      @feed ||= feeds.find(params[:id])
    end

    def feeds
      @feeds ||= Hunts::Feed.joins(:group)
                            .where(groups: { account: current_account })
    end

    def groups
      @groups ||= Group.where(account: current_account)
    end

    def feed_params
      params.require(:hunts_feed).permit(:group_id, :keyword, :source, system_hunts: [])
    end
  end
end
