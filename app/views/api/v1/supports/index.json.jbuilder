if @customer.agent_release_id.present?
  json.cache! ["v2/support-files/agent-release", @customer.agent_release], expires_in: 5.days do
    json.support_files @support_files.each do |file|
      json.name file.filename
      json.version file.md5
      json.url file.url
    end
  end
else
  json.cache! ["v3/support-files", @support_files], expires_in: 1.hour do
    # Only show the latest filename
    json.support_files @support_files.to_a.group_by(&:filename) do |_filename, uploads|
      file = uploads.max_by(&:created_at)

      json.name file.filename
      json.version file.md5
      json.url file.url
    end
  end
end
