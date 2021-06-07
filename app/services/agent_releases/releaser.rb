module AgentReleases
  # For each target group, find the latest release
  # Add possible customers to release
  class Releaser
    def call
      Account.agent_release_groups.values.each do |release_group|
        release = release_for_group(release_group)
        release.release_all_ready_customers! if release
      end
    end

    private

    def release_for_group(release_group)
      AgentRelease.order(:created_at).where("agent_release_groups @> '{?}'", release_group).last
    end
  end
end
