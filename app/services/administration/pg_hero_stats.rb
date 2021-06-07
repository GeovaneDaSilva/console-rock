module Administration
  # :nodoc
  class PgHeroStats
    def initialize(action)
      @action = action
    end

    def call
      return unless Rails.env.production?

      case @action
      when "clean"
        PgHero.clean_query_stats
      when "update"
        PgHero.capture_query_stats
        PgHero.capture_space_stats
      end
    end
  end
end
