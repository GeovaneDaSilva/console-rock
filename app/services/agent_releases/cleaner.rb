module AgentReleases
  # For each target group, find old releases
  # Only delete the release if all other target groups
  # have newer release
  class Cleaner
    KEEP_COUNT = 3

    def call
      Account.agent_release_groups.values.each do |release_group|
        releases = releases_for_group(release_group)

        releases.each do |release|
          release.destroy unless sibling_group_dependencies?(release)
        end
      end

      ServiceRunnerJob.set(queue: :utility).perform_later("AgentReleases::Releaser")
    end

    private

    def sibling_group_dependencies?(release)
      return false if release.agent_release_groups.size == 1

      release.agent_release_groups.collect do |release_group|
        newer_releases_for_group(release_group, release.created_at).positive?
      end.include?(false)
    end

    def releases_for_group(release_group)
      AgentRelease.order(created_at: :desc)
                  .where("agent_release_groups @> '{?}'", release_group)
                  .offset(KEEP_COUNT)
    end

    def newer_releases_for_group(release_group, date)
      releases_for_group(release_group).where("created_at > ?", date)
                                       .count
    end
  end
end
